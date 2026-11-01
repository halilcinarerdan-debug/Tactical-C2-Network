/*
    Fonksiyon: TC2_fnc_casTargets
    Çalışma yeri: SADECE SUNUCU (saf: yalnızca okur)

    JTAC'ın 9-Line gönderebileceği HAVA ARAÇ MÜRETTEBATINI (alıcıları) verir. Koşullar:
      - JTAC ile AYNI telsiz tipi + kanal ve JTAC'ın telsiz menzili içinde (Aşama 3 ağ kuralı),
      - hava aracında (Plane = sabit kanat "FW", diğer hava araçları = döner kanat "RW"),
      - canlı ve saha kaydı taze.
    Simüle test pilotları (debugCasPilot) da dahildir. TEST ayarı TC2_cas_allowSelf açıksa JTAC kendini de görür.

    Parametreler:
        0: JTAC birimi <OBJECT>
        1: telsiz tipi <STRING>
        2: kanal <NUMBER>

    Dönüş: [[netId, etiket, platform, mesafe m, simüle mi]] <ARRAY>
*/

params [["_jtac", objNull, [objNull]], ["_base", "", [""]], ["_channel", -1, [0]]];

if (_base isEqualTo "" || {isNull _jtac}) exitWith {[]};

private _range = [_base] call TC2_fnc_netRangeOf;
private _now = diag_tickTime;
private _jtacNet = netId _jtac;
private _out = [];

{
    _x params ["_netId", "_unit", "", "_unitBase", "_unitChannel", "_time"];
    private _vehicle = vehicle _unit;
    if (
        !(_netId isEqualTo _jtacNet) && {(_now - _time) < 25} && {alive _unit} && {_vehicle isKindOf "Air"}
        && {_unitBase isEqualTo _base} && {_unitChannel == _channel} && {(_jtac distance _unit) <= _range}
    ) then {
        _out pushBack [_netId, [format ["%1 (%2)", groupId (group _unit), name _unit], 40] call TC2_fnc_netSanitize, ["RW", "FW"] select (_vehicle isKindOf "Plane"), round (_jtac distance _unit), false];
    };
} forEach (missionNamespace getVariable ["TC2_cop_field", []]);

{
    _x params ["_netId", "_unit", "_simBase", "_simChannel", "_platform", "", "_label"];
    if ((_simBase isEqualTo _base) && {_simChannel == _channel} && {alive _unit} && {(_jtac distance _unit) <= _range}) then {
        _out pushBack [_netId, _label, _platform, round (_jtac distance _unit), true];
    };
} forEach (missionNamespace getVariable ["TC2_cas_simPilots", []]);

if (missionNamespace getVariable ["TC2_cas_allowSelf", false]) then {
    _out pushBack [_jtacNet, "SEN (TEST)", "RW", 0, false];
};

_out
