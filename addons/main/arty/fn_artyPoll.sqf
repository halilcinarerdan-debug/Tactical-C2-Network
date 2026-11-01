/*
    Fonksiyon: TC2_fnc_artyPoll
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_artyPoll", 2]
                  - host / tek oyunculuda: artyUiRequest doğrudan çağırır

    TOPÇU (gözlemci) ve FDC sekmelerinin verisi. Oturum doğrulanır. Yanıt:
      - rol bayrakları (gözlemci mi, FDC mi),
      - gözlemci için: CFF gönderebileceği FDC'ler, kendi son görevinin özeti,
      - FDC için: kendisine gelen görevler (kuyruk) ve tarafının bataryaları.
    Görev özeti: [id, durum, gözlemci adı, hedef no, grid, günlük, CFF satırları, batarya etiketi, faz, hacim, elle mi, danger close, gözlemci-hedef yönü, FDC adı]

    Parametreler:
        0: birim <OBJECT>
        1: terminal / saha cihazı <OBJECT>
        2: telsiz durumu <ARRAY>

    Dönüş: yok (yanıt: artyOnData)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_artyOnData", [_code, false, false, [], [], [], [], []]] call TC2_fnc_netToUnit;
};

[-1] call TC2_fnc_artyMissionIndex;

private _isObserver = [_unit, "OBSERVER"] call TC2_fnc_hasRole || {[_unit, "JTAC"] call TC2_fnc_hasRole};
private _isFdc = [_unit, "FDC"] call TC2_fnc_hasRole;
private _netId = netId _unit;

private _summarize = {
    params ["_m"];
    [
        _m select 0, _m select 7, _m select 3, _m select 9,
        if ((_m select 10) isEqualTo []) then {""} else {[_m select 10] call TC2_fnc_casGrid},
        +(_m select 14), [_m select 8, _m select 3, _m select 10] call TC2_fnc_artyLines, _m select 23, _m select 19,
        _m select 13, _m select 21, _m select 22, _m select 11, _m select 6
    ]
};

private _fdcTargets = [];
private _mine = [];
if (_isObserver) then {
    _fdcTargets = [_unit, _entry select 4, _entry select 5] call TC2_fnc_artyFdcTargets;
    {
        if ((_x select 1) isEqualTo _netId) then {_mine = [_x] call _summarize};
    } forEach (missionNamespace getVariable ["TC2_arty_missions", []]);
};

private _queue = [];
private _batteries = [];
if (_isFdc) then {
    {
        if ((_x select 4) isEqualTo _netId) then {_queue pushBack ([_x] call _summarize)};
    } forEach (missionNamespace getVariable ["TC2_arty_missions", []]);
    _batteries = ([side (group _unit)] call TC2_fnc_artyBatteries) apply {[_x select 0, _x select 1, _x select 2, count (_x select 3), _x select 4]};
};

private _targets = (missionNamespace getVariable ["TC2_arty_targets", []]) apply {[_x select 0, [_x select 1] call TC2_fnc_casGrid]};

[_unit, "TC2_fnc_artyOnData", ["OK", _isObserver, _isFdc, _fdcTargets, _mine, _queue, _batteries, _targets]] call TC2_fnc_netToUnit;
