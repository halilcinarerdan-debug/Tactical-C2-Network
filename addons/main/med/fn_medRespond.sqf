/*
    Fonksiyon: TC2_fnc_medRespond
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_medRespond", 2]
                  - host / tek oyunculuda: medCrewAction doğrudan çağırır

    Hava aracı mürettebatı MEDEVAC talebini KABUL eder (ACE self menüsünden). Sunucu doğrulamaları: gönderen, birim canlı ve hava aracında,
    birim talebin alıcı listesinde (talep gönderilirken ağdaki mürettebat), talep hâlâ AÇIK. Terminal oturumu ya da tablet istemez (hava aracı muafiyeti).

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

if (_request isEqualTo [] || {!(alive _unit)} || {!((vehicle _unit) isKindOf "Air")} || {!((netId _unit) in (_request select 13))}) exitWith {
    diag_log format ["[TC2][MEDEVAC] RED kabul id=%1 birim=%2", _id, name _unit];
    [_unit, "TC2_fnc_medOnAck", ["NOT_ALLOWED", [_id]]] call TC2_fnc_netToUnit;
};

switch (_request select 8) do {
    case "CANCELLED": {[_unit, "TC2_fnc_medOnAck", ["CANCELLED", [_id]]] call TC2_fnc_netToUnit};
    case "ACCEPTED": {[_unit, "TC2_fnc_medOnAck", ["TAKEN", [_id]]] call TC2_fnc_netToUnit};
    default {
        private _callsign = [groupId (group _unit), 24] call TC2_fnc_netSanitize;
        if ([_id, netId _unit, _callsign, getPosASL (vehicle _unit)] call TC2_fnc_medAccept) then {
            [_unit, "TC2_fnc_medOnAck", ["ACCEPTED_OK", [_id, _request select 11]]] call TC2_fnc_netToUnit;
        };
    };
};
