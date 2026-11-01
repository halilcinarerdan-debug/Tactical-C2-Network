/*
    Fonksiyon: TC2_fnc_medAccept
    Çalışma yeri: SADECE SUNUCU (medRespond ve simüle mürettebat çağırır)

    Açık bir MEDEVAC talebini kabul eder: durum KABUL olur, tahmini varış süresi hesaplanır (alım yerine düz mesafe / 55 m/s, en az 1 dk),
    talep sahibine ve diğer alıcılara bildirilir, ağa bilgi satırı düşer.

    Parametreler:
        0: talep id <NUMBER>   1: kabul eden netId <STRING>   2: kabul eden çağrı adı <STRING>   3: kabul edenin konumu <ARRAY>

    Dönüş: <BOOL> kabul edildi mi
*/

if (!isServer) exitWith {false};

params [["_id", -1, [0]], ["_netId", "", [""]], ["_callsign", "", [""]], ["_position", [0, 0, 0], [[]]]];

private _requests = missionNamespace getVariable ["TC2_med_requests", []];
private _request = [];
{
    if ((_x select 0) == _id) exitWith {_request = _x};
} forEach _requests;

if (_request isEqualTo [] || {!((_request select 8) isEqualTo "OPEN")}) exitWith {false};

private _eta = ceil (((_position distance2D (_request select 12)) / 55 / 60) max 1);
_request set [8, "ACCEPTED"];
_request set [9, _netId];
_request set [10, _callsign];
_request set [11, _eta];

diag_log format ["[TC2][MEDEVAC] KABUL id=%1 | mürettebat=%2 | eta=%3 dk", _id, _callsign, _eta];

[_request select 2, "TC2_fnc_medOnUpdate", [_id, "ACCEPTED", _callsign, _eta]] call TC2_fnc_netToUnit;
{
    if (!(_x isEqualTo _netId)) then {
        private _unit = objectFromNetId _x;
        if (!isNull _unit) then {[_unit, "TC2_fnc_medOnUpdate", [_id, "TAKEN", _callsign, _eta]] call TC2_fnc_netToUnit};
    };
} forEach (_request select 13);

[_request select 1, format ["MEDEVAC #%1 KABUL: %2, tahmini varış %3 dk", _id, _callsign, _eta]] call TC2_fnc_netInfo;

true
