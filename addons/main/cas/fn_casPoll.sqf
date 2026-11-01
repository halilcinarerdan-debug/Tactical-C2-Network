/*
    Fonksiyon: TC2_fnc_casPoll
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_casPoll", 2]
                  - host / tek oyunculuda: casUiRequest doğrudan çağırır

    CAS sekmesinin verisi: bu birim JTAC mi, alıcı olabilecek mürettebat listesi ve bu JTAC'ın en son talebinin durumu.
    Oturum doğrulanır (erişim + telsiz). JTAC yetkisi, objede `TC2_jtac` değişkeni (true) ile belirlenir.

    Parametreler:
        0: birim <OBJECT>
        1: terminal <OBJECT>
        2: telsiz durumu <ARRAY>

    Dönüş: yok (yanıt: casOnData)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_casOnData", [_code, false, [], []]] call TC2_fnc_netToUnit;
};

[-1] call TC2_fnc_casReqIndex;

private _isJtac = _unit getVariable ["TC2_jtac", false];
private _targets = [_unit, _entry select 4, _entry select 5] call TC2_fnc_casTargets;

private _mine = [];
private _jtacNet = netId _unit;
{
    if ((_x select 1) isEqualTo _jtacNet) then {_mine = _x};
} forEach (missionNamespace getVariable ["TC2_cas_requests", []]);

private _summary = [];
if !(_mine isEqualTo []) then {
    _summary = [_mine select 0, _mine select 7, _mine select 13, _mine select 8, _mine select 5, _mine select 6];
};

[_unit, "TC2_fnc_casOnData", ["OK", _isJtac, _targets, _summary]] call TC2_fnc_netToUnit;
