/*
    Fonksiyon: TC2_fnc_medSend
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_medSend", 2]
                  - host / tek oyunculuda: medUiSend doğrudan çağırır

    9-Line MEDEVAC talebini ağdaki HELİKOPTER mürettebatına iletir. Sunucu doğrulamaları: gönderen, oturum (telsiz ağı şart), yazma yetkisi
    (izleme modu değil ve seviye >= 2), form (medValidate; metinler temizlenir), alım yeri (kendi konumu ya da görebildiği işaret),
    gönderim aralığı (3 sn), alıcı var mı (aynı tip + kanal + menzilde en az bir helikopter mürettebatı; sabit kanat dahil değil).
    Her gönderenin tek etkin talebi vardır; yenisi eskisini iptal eder. Simüle mürettebat (debugCasPilot ile eklenen, platform RW) 4 sn sonra kabul eder.

    Parametreler:
        0: gönderen <OBJECT>   1: terminal / saha cihazı <OBJECT>   2: telsiz durumu <ARRAY>   3: veri <ARRAY of STRING>

    Dönüş: yok (yanıt: medOnAck)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_data", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_medOnAck", [_code, []]] call TC2_fnc_netToUnit;
};

if ((_entry param [9, "DESK"]) isEqualTo "VIEW" || {([_unit, _terminal] call TC2_fnc_accessLevel) < 2}) exitWith {
    diag_log format ["[TC2][MEDEVAC] RED: yazma yetkisi yok (%1)", name _unit];
    [_unit, "TC2_fnc_medOnAck", [if ((_entry param [9, "DESK"]) isEqualTo "VIEW") then {"VIEW_ONLY"} else {"NO_LEVEL"}, []]] call TC2_fnc_netToUnit;
};

private _now = diag_tickTime;
if ((_now - (_entry select 8)) < 3) exitWith {
    [_unit, "TC2_fnc_medOnAck", ["COOLDOWN", []]] call TC2_fnc_netToUnit;
};

_data = _data apply {if (_x isEqualType "") then {[_x, 40] call TC2_fnc_netSanitize} else {_x}};

private _check = [_data] call TC2_fnc_medValidate;
if !(_check select 0) exitWith {
    [_unit, "TC2_fnc_medOnAck", ["INVALID", _check select 1]] call TC2_fnc_netToUnit;
};

private _base = _entry select 4;
private _channel = _entry select 5;

// Alım yeri
private _position = getPosASL _unit;
private _location = _data select 0;
if ((_location select [0, 1]) isEqualTo "M") then {
    private _markerId = parseNumber (_location select [1, (count _location) - 1]);
    private _found = [];
    {
        if ((_x select 0) == _markerId) exitWith {_found = _x select 2};
    } forEach ([_base, _channel, _unit] call TC2_fnc_copMarkersFor);
    _position = _found;
};
if (_position isEqualTo []) exitWith {
    [_unit, "TC2_fnc_medOnAck", ["NO_POS", []]] call TC2_fnc_netToUnit;
};

// Alıcılar: ağdaki helikopter mürettebatı
private _targets = ([_unit, _base, _channel] call TC2_fnc_casTargets) select {(_x select 2) isEqualTo "RW"};
if (_targets isEqualTo []) exitWith {
    [_unit, "TC2_fnc_medOnAck", ["NO_CREW", []]] call TC2_fnc_netToUnit;
};

_entry set [8, _now];

// Eski etkin talebi iptal et
private _senderNet = netId _unit;
private _requests = (missionNamespace getVariable ["TC2_med_requests", []]) select {(_now - (_x select 5)) < 7200};
{
    private _old = _x;
    if ((_old select 1) isEqualTo _senderNet && {!((_old select 8) isEqualTo "CANCELLED")}) then {
        _old set [8, "CANCELLED"];
        {
            private _crew = objectFromNetId _x;
            if (!isNull _crew) then {[_crew, "TC2_fnc_medOnUpdate", [_old select 0, "CANCELLED", "", 0]] call TC2_fnc_netToUnit};
        } forEach (_old select 13);
    };
} forEach _requests;

private _id = (missionNamespace getVariable ["TC2_med_nextId", 0]) + 1;
missionNamespace setVariable ["TC2_med_nextId", _id];

private _callsign = [groupId (group _unit), 24] call TC2_fnc_netSanitize;
private _recipients = _targets apply {_x select 0};
_requests pushBack [_id, _senderNet, _unit, _callsign, _data, _now, _base, _channel, "OPEN", "", "", 0, _position, _recipients];
while {count _requests > 30} do {_requests deleteAt 0};
missionNamespace setVariable ["TC2_med_requests", _requests];

diag_log format ["[TC2][MEDEVAC] GONDERILDI id=%1 | gonderen=%2 (%3) | alicilar=%4 | ag=%5 K%6", _id, name _unit, _callsign, count _recipients, _base, _channel];

[_unit, "TC2_fnc_medOnAck", ["SENT", [_id, count _recipients]]] call TC2_fnc_netToUnit;
[_senderNet, format ["MEDEVAC #%1  %2  (%3 alıcı)", _id, _callsign, count _recipients]] call TC2_fnc_netInfo;

private _lines = [_data, [[_position] call TC2_fnc_casGrid, _callsign, format ["%1 K%2", _base, _channel]]] call TC2_fnc_medLines;

{
    _x params ["_netId", "_label", "", "", "_sim"];
    if (_sim) then {
        // Simüle mürettebat: 4 sn sonra kabul eder.
        [{
            params ["_id", "_netId", "_label"];
            private _crew = objectFromNetId _netId;
            [_id, _netId, _label, if (isNull _crew) then {[0, 0, 0]} else {getPosASL _crew}] call TC2_fnc_medAccept;
        }, [_id, _netId, _label], 4] call CBA_fnc_waitAndExecute;
    } else {
        private _crew = objectFromNetId _netId;
        if (!isNull _crew) then {[_crew, "TC2_fnc_medOnIncoming", [_id, _callsign, _lines, _data select 10]] call TC2_fnc_netToUnit};
    };
} forEach _targets;
