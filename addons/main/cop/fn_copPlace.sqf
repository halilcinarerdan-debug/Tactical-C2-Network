/*
    Fonksiyon: TC2_fnc_copPlace
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_copPlace", 2]
                  - host / tek oyunculuda: copUiClick doğrudan çağırır

    Haritaya düşman işareti koyar. Sunucu doğrulamaları: gönderen, oturum (erişim + telsiz envanterde mi),
    tür listesi, konum biçimi, eylem aralığı (1.5 sn), ağ başına en fazla 30 işaret.
    İşaret AĞA aittir (telsiz tipi + kanal); görünürlük kuralı için bkz. copMarkersFor.
    Başarıda ağdaki liderlerin MicroDAGR'ı anında güncellenir (copPush). Her işlem RPT'ye "[TC2][COP]".

    Parametreler:
        0: birim <OBJECT>
        1: terminal <OBJECT>
        2: telsiz durumu <ARRAY>
        3: tür <STRING>  (copTypeCatalog kodu: "INF", "ART", "MINE" ...)
        4: konum ASL <ARRAY>

    Dönüş: yok (yanıt: copOnAck)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_type", "", [""]], ["_pos", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

if !(([_type] call TC2_fnc_copTypeInfo) select 4) exitWith {};
if !(count _pos == 3 && {(_pos select 0) isEqualType 0} && {(_pos select 1) isEqualType 0} && {(_pos select 2) isEqualType 0}) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_copOnAck", [_code, ""]] call TC2_fnc_netToUnit;
};

if ((_entry param [9, "DESK"]) isEqualTo "VIEW") exitWith {
    [_unit, "TC2_fnc_copOnAck", ["VIEW_ONLY", ""]] call TC2_fnc_netToUnit;
};

private _now = diag_tickTime;
if ((_now - (_entry select 8)) < 1.5) exitWith {
    [_unit, "TC2_fnc_copOnAck", ["COOLDOWN", ""]] call TC2_fnc_netToUnit;
};

private _base = _entry select 4;
private _channel = _entry select 5;

private _count = count ((missionNamespace getVariable ["TC2_cop_markers", []]) select {((_x select 3) isEqualTo _base) && {(_x select 4) == _channel}});
if (_count >= 30) exitWith {
    [_unit, "TC2_fnc_copOnAck", ["LIMIT", ""]] call TC2_fnc_netToUnit;
};

_entry set [8, _now];

private _id = (missionNamespace getVariable ["TC2_cop_nextId", 0]) + 1;
missionNamespace setVariable ["TC2_cop_nextId", _id];

private _label = [format ["%1 / %2", name _unit, _entry select 2], 60] call TC2_fnc_netSanitize;
private _rounded = _pos apply {round _x};

private _markers = missionNamespace getVariable ["TC2_cop_markers", []];
_markers pushBack [_id, _type, _rounded, _base, _channel, _label, netId _unit, _now, getPosASL _unit];
missionNamespace setVariable ["TC2_cop_markers", _markers];

diag_log format ["[TC2][COP] KOYULDU id=%1 tur=%2 konum=%3 | koyan=%4 | ag=%5 K%6", _id, _type, _rounded, name _unit, _base, _channel];

[_unit, "TC2_fnc_copOnAck", ["PLACED", mapGridPosition _rounded]] call TC2_fnc_netToUnit;

[_base, _channel] call TC2_fnc_copPush;
