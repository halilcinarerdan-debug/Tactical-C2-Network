/*
    Fonksiyon: TC2_fnc_copRemove
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_copRemove", 2]
                  - host / tek oyunculuda: copUiClick doğrudan çağırır

    Bir düşman işaretini siler. Yalnızca o işareti GÖREBİLEN (aynı ağ + menzil içinde) ve geçerli oturumu olan
    terminal kullanıcısı silebilir. Başarıda ağdaki liderlerin MicroDAGR'ı güncellenir.

    Parametreler:
        0: birim <OBJECT>
        1: terminal <OBJECT>
        2: telsiz durumu <ARRAY>
        3: işaret id <NUMBER>

    Dönüş: yok (yanıt: copOnAck)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_id", -1, [0]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_copOnAck", [_code, ""]] call TC2_fnc_netToUnit;
};

private _base = _entry select 4;
private _channel = _entry select 5;

private _visible = [_base, _channel, _unit] call TC2_fnc_copMarkersFor;
private _found = _visible select {(_x select 0) == _id};

if (_found isEqualTo []) exitWith {
    [_unit, "TC2_fnc_copOnAck", ["NOT_FOUND", ""]] call TC2_fnc_netToUnit;
};

missionNamespace setVariable ["TC2_cop_markers", (missionNamespace getVariable ["TC2_cop_markers", []]) select {(_x select 0) != _id}];

diag_log format ["[TC2][COP] SILINDI id=%1 | silen=%2 | ag=%3 K%4", _id, name _unit, _base, _channel];

[_unit, "TC2_fnc_copOnAck", ["REMOVED", ""]] call TC2_fnc_netToUnit;

[_base, _channel] call TC2_fnc_copPush;
