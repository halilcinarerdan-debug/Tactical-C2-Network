/*
    Fonksiyon: TC2_fnc_artySendCff
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_artySendCff", 2]
                  - host / tek oyunculuda: artyUiSend doğrudan çağırır

    Call for fire (CFF) gönderir; FDC operatörüne iletir. Sunucu doğrulamaları (hepsi zorunlu):
      1. gönderen (remoteExecutedOwner), 2. oturum (terminal ya da saha cihazı, telsiz envanterde),
      3. gözlemci / JTAC yetkisi (hasRole), 4. gönderim aralığı (3 sn), 5. alıcı FDC gözlemcinin ağında ve menzilde,
      6. form doktrine uygun (artyValidate; metinler temizlenir), 7. konum çözülebiliyor (GRID/POLAR/SHIFT),
      8. DANGER CLOSE: hedef dostlara 600 m ya da daha yakınsa ve gözlemci bildirmediyse REDDEDİLİR (ATP 3-09.30, 4-35).
    Gözlemci başına tek etkin görev vardır; yenisi eskisini iptal eder. Gözlemci-hedef yönü (mil) otomatik hesaplanır
    (gözlemci 10 mile yuvarlayarak ölçmüş gibi). Başarıda FDC'ye bip + günlük satırı, gözlemciye ack, ağa üs bilgisi.

    Parametreler:
        0: gözlemci birimi <OBJECT>
        1: terminal / saha cihazı <OBJECT>
        2: telsiz durumu <ARRAY>
        3: CFF verisi <ARRAY>   (bkz. artyValidate)
        4: alıcı FDC netId <STRING>

    Dönüş: yok (yanıt: artyOnAck)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_data", [], [[]]], ["_fdcNet", "", [""]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_artyOnAck", [_code, []]] call TC2_fnc_netToUnit;
};

if !([_unit, _terminal, "ARTY"] call TC2_fnc_canWriteFires) exitWith {
    diag_log format ["[TC2][TOPCU] RED NOT_OBSERVER birim=%1", name _unit];
    [_unit, "TC2_fnc_artyOnAck", ["NOT_OBSERVER", []]] call TC2_fnc_netToUnit;
};

private _now = diag_tickTime;
if ((_now - (_entry select 8)) < 3) exitWith {
    [_unit, "TC2_fnc_artyOnAck", ["COOLDOWN", []]] call TC2_fnc_netToUnit;
};

private _base = _entry select 4;
private _channel = _entry select 5;

private _fdcLabel = "";
{
    if ((_x select 0) isEqualTo _fdcNet) exitWith {_fdcLabel = _x select 1};
} forEach ([_unit, _base, _channel] call TC2_fnc_artyFdcTargets);

if (_fdcLabel isEqualTo "") exitWith {
    [_unit, "TC2_fnc_artyOnAck", ["NO_FDC", []]] call TC2_fnc_netToUnit;
};

// Serbest metin alanlarını temizle (structured text olarak gösterilecek).
_data = _data apply {if (_x isEqualType "") then {[_x, 100] call TC2_fnc_netSanitize} else {_x}};

private _validation = [_data] call TC2_fnc_artyValidate;
if !(_validation select 0) exitWith {
    [_unit, "TC2_fnc_artyOnAck", ["INVALID", _validation select 1]] call TC2_fnc_netToUnit;
};

private _position = [_data, _unit, _base, _channel] call TC2_fnc_artyResolvePos;
if (_position isEqualTo []) exitWith {
    [_unit, "TC2_fnc_artyOnAck", ["NO_POS", []]] call TC2_fnc_netToUnit;
};

// Ateş yasak alanı (NFA) denetimi; kısıtlı ateş alanı (RFA) yalnızca uyarı verir.
private _zone = [_position] call TC2_fnc_fscmCheck;
if ((_zone select 0) isEqualTo "NFA") exitWith {
    diag_log format ["[TC2][TOPCU] RED NFA hedef=%1 alan=%2 gozlemci=%3", _position, _zone select 1, name _unit];
    [_unit, "TC2_fnc_artyOnAck", ["NFA", []]] call TC2_fnc_netToUnit;
};

// DANGER CLOSE denetimi (600 m)
private _near = [_position, side (group _unit)] call TC2_fnc_artyNearestFriendly;
if ((_near select 0) <= 600 && {!(_data select 8)}) exitWith {
    [_unit, "TC2_fnc_artyOnAck", ["DANGER_CLOSE", [round (_near select 0), _near select 1]]] call TC2_fnc_netToUnit;
};

_entry set [8, _now];

// Gözlemcinin eski etkin görevini iptal et.
private _observerNet = netId _unit;
private _missions = missionNamespace getVariable ["TC2_arty_missions", []];
{
    if ((_x select 1) isEqualTo _observerNet && {!((_x select 7) in ["EOM", "REJECTED", "CANCELLED"])}) then {
        _x set [7, "CANCELLED"];
        [_x select 0, "Gözlemci yeni bir CFF gönderdi; önceki görev iptal edildi.", "INFO", "FDC"] call TC2_fnc_artyEvent;
    };
} forEach _missions;

private _id = (missionNamespace getVariable ["TC2_arty_nextId", 0]) + 1;
missionNamespace setVariable ["TC2_arty_nextId", _id];

private _observerCallsign = [groupId (group _unit), 24] call TC2_fnc_netSanitize;
private _fdcUnit = objectFromNetId _fdcNet;
private _direction = (round (([_unit getDir _position, "TOMIL"] call TC2_fnc_artyMilsToDeg) / 10) * 10) mod 6400;
private _phase = ["FFE", "ADJUST"] select ((_data select 0) isEqualTo "ADJUST");

_missions pushBack [
    _id, _observerNet, _unit, _observerCallsign, _fdcNet, _fdcUnit, _fdcLabel, "REQUEST", _data, "", _position, _direction,
    [], _data select 12, [], _now, _base, _channel, 0, _phase, 0, false, _data select 8, "", "", ""
];
missionNamespace setVariable ["TC2_arty_missions", _missions];

diag_log format ["[TC2][TOPCU] CFF id=%1 | gozlemci=%2 | fdc=%3 | gorev=%4 yontem=%5 | hedef=%6", _id, name _unit, _fdcLabel, _data select 0, _data select 1, _position];

private _typeText = switch (_data select 0) do {
    case "ADJUST":    {"ADJUST FIRE"};
    case "FFE":       {"FIRE FOR EFFECT"};
    case "SUPPRESS":  {"SUPPRESS"};
    case "IMM_SUPP":  {"IMMEDIATE SUPPRESSION"};
    case "IMM_SMOKE": {"IMMEDIATE SMOKE"};
    default {""};
};

[_id, format ["CFF #%1  %2  %3", _id, _observerCallsign, _typeText], "BEEP", "FDC"] call TC2_fnc_artyEvent;
[_id, format ["%1, bu %2, %3, GRID %4, OVER.", _fdcLabel, _observerCallsign, _typeText, [_position] call TC2_fnc_casGrid], "INFO", "OBS"] call TC2_fnc_artyEvent;

[_unit, "TC2_fnc_artyOnAck", ["SENT", [_id, _fdcLabel]]] call TC2_fnc_netToUnit;

[_observerNet, format ["TOPÇU #%1  gözlemci %2  FDC %3  %4%5", _id, _observerCallsign, _fdcLabel, _typeText, ["", "  | UYARI: hedef RFA içinde (" + (_zone select 1) + ")"] select ((_zone select 0) isEqualTo "RFA")]] call TC2_fnc_netInfo;
