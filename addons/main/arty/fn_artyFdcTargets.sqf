/*
    Fonksiyon: TC2_fnc_artyFdcTargets
    Çalışma yeri: SADECE SUNUCU (saf)

    Gözlemcinin CFF gönderebileceği FDC operatörlerini verir: gözlemciyle AYNI telsiz tipi + kanal + menzilde olan,
    FDC rolüne sahip, canlı oyuncular (saha varlığı kaydından). TEST ayarı TC2_arty_allowSelf açıksa gözlemci kendini de görür.

    Parametreler:
        0: gözlemci birimi <OBJECT>
        1: telsiz tipi <STRING>
        2: kanal <NUMBER>

    Dönüş: [[netId, çağrı adı]] <ARRAY>
*/

params [["_observer", objNull, [objNull]], ["_base", "", [""]], ["_channel", -1, [0]]];

if (_base isEqualTo "" || {isNull _observer}) exitWith {[]};

private _range = [_base] call TC2_fnc_netRangeOf;
private _now = diag_tickTime;
private _observerNet = netId _observer;
private _out = [];

{
    _x params ["_netId", "_unit", "", "_unitBase", "_unitChannel", "_time"];
    if (
        !(_netId isEqualTo _observerNet) && {(_now - _time) < 25} && {alive _unit} && {[_unit, "FDC"] call TC2_fnc_hasRole}
        && {_unitBase isEqualTo _base} && {_unitChannel == _channel} && {(_observer distance _unit) <= _range}
    ) then {
        _out pushBack [_netId, [format ["%1 (%2)", groupId (group _unit), name _unit], 40] call TC2_fnc_netSanitize];
    };
} forEach (missionNamespace getVariable ["TC2_cop_field", []]);

if (missionNamespace getVariable ["TC2_arty_allowSelf", false]) then {
    _out pushBack [_observerNet, "SEN (TEST)"];
};

_out
