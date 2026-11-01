/*
    Fonksiyon: TC2_fnc_rptSend
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_rptSend", 2]
                  - host / tek oyunculuda: rptUiSend doğrudan çağırır

    Saha raporu gönderir: SALUTE (düşman gözlemi), SITREP (durum), LACE (Liquids, Ammunition, Casualties, Equipment).
    Sunucu doğrulamaları: gönderen, oturum (telsiz ağı şart), YAZMA yetkisi (mod VIEW değil ve seviye >= 2: er tabletle yazamaz,
    Kırmızı kart (Level 1) masa başında yazamaz), form (rptValidate; metinler temizlenir), SALUTE konumu (kendi konumu ya da görebildiği işaret),
    gönderim aralığı (3 sn). LACE'e sistemin doğruladığı sayılar eklenir (rptLaceInfo). Rapor, aynı ağdaki (tip + kanal + menzil) Level 2+ oturumlara gider.
    SALUTE raporları S2 / CO DOĞRULAMADAN "doğrulanmamış" sayılır (haritada soru işaretli simge); doğrulanınca düşman işareti olur.

    Parametreler:
        0: gönderen <OBJECT>   1: terminal / saha cihazı <OBJECT>   2: telsiz durumu <ARRAY>
        3: tür <STRING>        4: veri <ARRAY of STRING>

    Dönüş: yok (yanıt: rptOnAck)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_type", "", [""]], ["_data", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_rptOnAck", [_code, []]] call TC2_fnc_netToUnit;
};

if ((_entry param [9, "DESK"]) isEqualTo "VIEW" || {([_unit, _terminal] call TC2_fnc_accessLevel) < 2}) exitWith {
    diag_log format ["[TC2][RAPOR] RED: yazma yetkisi yok (%1)", name _unit];
    [_unit, "TC2_fnc_rptOnAck", [if ((_entry param [9, "DESK"]) isEqualTo "VIEW") then {"VIEW_ONLY"} else {"NO_LEVEL"}, []]] call TC2_fnc_netToUnit;
};

private _now = diag_tickTime;
if ((_now - (_entry select 8)) < 3) exitWith {
    [_unit, "TC2_fnc_rptOnAck", ["COOLDOWN", []]] call TC2_fnc_netToUnit;
};

_data = _data apply {if (_x isEqualType "") then {[_x, 120] call TC2_fnc_netSanitize} else {_x}};

private _check = [_type, _data] call TC2_fnc_rptValidate;
if !(_check select 0) exitWith {
    [_unit, "TC2_fnc_rptOnAck", ["INVALID", _check select 1]] call TC2_fnc_netToUnit;
};

private _base = _entry select 4;
private _channel = _entry select 5;

// konum: SALUTE'ta seçilen; diğerlerinde göndericinin konumu
private _position = getPosASL _unit;
if (_type isEqualTo "SALUTE") then {
    private _location = _data select 2;
    if ((_location select [0, 1]) isEqualTo "M") then {
        private _id = parseNumber (_location select [1, (count _location) - 1]);
        private _found = [];
        {
            if ((_x select 0) == _id) exitWith {_found = _x select 2};
        } forEach ([_base, _channel, _unit] call TC2_fnc_copMarkersFor);
        if (_found isEqualTo []) then {_position = []} else {_position = _found};
    };
};
if (_position isEqualTo []) exitWith {
    [_unit, "TC2_fnc_rptOnAck", ["NO_POS", []]] call TC2_fnc_netToUnit;
};

_entry set [8, _now];

private _id = (missionNamespace getVariable ["TC2_rpt_nextId", 0]) + 1;
missionNamespace setVariable ["TC2_rpt_nextId", _id];

private _callsign = [groupId (group _unit), 24] call TC2_fnc_netSanitize;
private _auto = if (_type isEqualTo "LACE") then {([group _unit] call TC2_fnc_rptLaceInfo) select 0} else {[]};

private _reports = (missionNamespace getVariable ["TC2_reports", []]) select {(_now - (_x select 5)) < 10800};
_reports pushBack [_id, _type, netId _unit, _callsign, _data, _now, _base, _channel, false, _position, netId (group _unit), _auto, _unit];
while {count _reports > 80} do {_reports deleteAt 0};
missionNamespace setVariable ["TC2_reports", _reports];

diag_log format ["[TC2][RAPOR] %1 id=%2 | gonderen=%3 (%4) | ag=%5 K%6 | konum=%7", _type, _id, name _unit, _callsign, _base, _channel, _position];

[_unit, "TC2_fnc_rptOnAck", ["SENT", [_id, _type]]] call TC2_fnc_netToUnit;
[netId _unit, format ["RAPOR #%1  %2  %3", _id, _type, _callsign]] call TC2_fnc_netInfo;
