/*
    Fonksiyon: TC2_fnc_casAbort
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_casAbort", 2]
                  - host / tek oyunculuda: casUiAbort doğrudan çağırır

    Talebi iptal eder. Doktrin: JTAC iptal yetkisini her zaman elinde tutar. Yalnızca talebin sahibi JTAC iptal edebilir.
    Pilota (gerçek ise) bildirilir.

    Parametreler:
        0: JTAC birimi <OBJECT>
        1: terminal <OBJECT>
        2: telsiz durumu <ARRAY>
        3: talep id <NUMBER>

    Dönüş: yok (yanıt: casOnAck)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_id", -1, [0]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_casOnAck", [_code, []]] call TC2_fnc_netToUnit;
};

private _index = [_id] call TC2_fnc_casReqIndex;
if (_index < 0) exitWith {
    [_unit, "TC2_fnc_casOnAck", ["NOT_FOUND", []]] call TC2_fnc_netToUnit;
};

private _request = (missionNamespace getVariable ["TC2_cas_requests", []]) select _index;

if !((_request select 1) isEqualTo (netId _unit)) exitWith {
    diag_log format ["[TC2][CAS] IPTAL RED id=%1 | sahibi degil: %2", _id, name _unit];
};

_request set [7, "ABORTED"];
diag_log format ["[TC2][CAS] IPTAL id=%1 | jtac=%2", _id, name _unit];

if (!(_request select 14) && {!isNull (_request select 4)}) then {
    [_request select 4, "TC2_fnc_casOnResult", [_id, "ABORTED", _request select 8]] call TC2_fnc_netToUnit;
};

[netId _unit, format ["CAS #%1  İPTAL EDİLDİ (JTAC)", _id]] call TC2_fnc_netInfo;

[_unit, "TC2_fnc_casOnAck", ["ABORTED", []]] call TC2_fnc_netToUnit;
