/*
    Fonksiyon: TC2_fnc_rptVerify
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_rptVerify", 2]
                  - host / tek oyunculuda: rptUiVerify doğrudan çağırır

    S2 (İstihbarat Subayı) ya da CO (Bölük Komutanı) bir SALUTE raporunu DOĞRULAR: rapor "doğrulandı" olur ve raporun konumunda
    düşman işareti (DÜŞMAN PİYADE) oluşur; işaret ağdaki terminallere ve liderlerin MicroDAGR'ına gider. Doğrulanmamış SALUTE'lar yalnızca
    soru işaretli simgedir (bilgi güvenirliği). Doğrulama RPT'ye yazılır.

    Parametreler:
        0: birim <OBJECT>   1: terminal / saha cihazı <OBJECT>   2: telsiz durumu <ARRAY>   3: rapor id <NUMBER>

    Dönüş: yok (yanıt: rptOnAck)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_id", -1, [0]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_rptOnAck", [_code, []]] call TC2_fnc_netToUnit;
};

if !([_unit, "S2"] call TC2_fnc_hasRole || {[_unit, "CO"] call TC2_fnc_hasRole}) exitWith {
    diag_log format ["[TC2][RAPOR] RED: dogrulama yetkisi yok (%1)", name _unit];
    [_unit, "TC2_fnc_rptOnAck", ["NOT_S2", []]] call TC2_fnc_netToUnit;
};

private _report = [];
{
    if ((_x select 0) == _id) exitWith {_report = _x};
} forEach (missionNamespace getVariable ["TC2_reports", []]);

if (_report isEqualTo [] || {!((_report select 1) isEqualTo "SALUTE")}) exitWith {
    [_unit, "TC2_fnc_rptOnAck", ["NOT_FOUND", []]] call TC2_fnc_netToUnit;
};
if (_report select 8) exitWith {
    [_unit, "TC2_fnc_rptOnAck", ["ALREADY", []]] call TC2_fnc_netToUnit;
};

_report set [8, true];

private _markerId = (missionNamespace getVariable ["TC2_cop_nextId", 0]) + 1;
missionNamespace setVariable ["TC2_cop_nextId", _markerId];
private _label = [format ["SALUTE #%1 / S2 %2", _id, name _unit], 60] call TC2_fnc_netSanitize;
private _markers = missionNamespace getVariable ["TC2_cop_markers", []];
_markers pushBack [_markerId, "INF", (_report select 9) apply {round _x}, _report select 6, _report select 7, _label, netId _unit, diag_tickTime, getPosASL _unit];
missionNamespace setVariable ["TC2_cop_markers", _markers];

diag_log format ["[TC2][RAPOR] DOGRULANDI SALUTE id=%1 | dogrulayan=%2 | isaret=%3", _id, name _unit, _markerId];

[_unit, "TC2_fnc_rptOnAck", ["VERIFIED", [_id]]] call TC2_fnc_netToUnit;
[netId _unit, format ["SALUTE #%1 doğrulandı (S2): düşman işareti haritada", _id]] call TC2_fnc_netInfo;

[_report select 6, _report select 7] call TC2_fnc_copPush;
