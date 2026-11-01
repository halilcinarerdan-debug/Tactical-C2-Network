/*
    Fonksiyon: TC2_fnc_medCancel
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_medCancel", 2]
                  - host / tek oyunculuda: medUiCancel doğrudan çağırır

    Talep sahibi kendi MEDEVAC talebini iptal eder (açık ya da kabul edilmiş). Alıcı mürettebata iptal bildirilir. Yetki: yalnızca talebi gönderen.

    Parametreler:
        0: birim <OBJECT>   1: talep id <NUMBER>

    Dönüş: yok (yanıt: medOnAck)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_id", -1, [0]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _request = [];
{
    if ((_x select 0) == _id) exitWith {_request = _x};
} forEach (missionNamespace getVariable ["TC2_med_requests", []]);

if (_request isEqualTo [] || {!((_request select 1) isEqualTo (netId _unit))} || {(_request select 8) isEqualTo "CANCELLED"}) exitWith {
    [_unit, "TC2_fnc_medOnAck", ["NOT_ALLOWED", [_id]]] call TC2_fnc_netToUnit;
};

_request set [8, "CANCELLED"];

{
    private _crew = objectFromNetId _x;
    if (!isNull _crew) then {[_crew, "TC2_fnc_medOnUpdate", [_id, "CANCELLED", "", 0]] call TC2_fnc_netToUnit};
} forEach (_request select 13);

diag_log format ["[TC2][MEDEVAC] IPTAL id=%1 | gonderen=%2", _id, name _unit];
[_unit, "TC2_fnc_medOnAck", ["CANCELLED_OK", [_id]]] call TC2_fnc_netToUnit;
[netId _unit, format ["MEDEVAC #%1 iptal edildi", _id]] call TC2_fnc_netInfo;
