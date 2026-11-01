/*
    Fonksiyon: TC2_fnc_medPoll
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_medPoll", 2]
                  - host / tek oyunculuda: medUiRequest doğrudan çağırır

    MEDEVAC sekmesinin verisi: izleyenin AYNI ağındaki (tip + kanal + gönderen menzilinde) son 8 talep, durumlarıyla. Level 2 altı ve izleme modu
    HİÇ talep görmez. Yanıt: kod, seviye, yazabilir mi, talepler [id, çağrı adı, yaş sn, durum, kabul eden, ETA dk, benim mi, satırlar].

    Parametreler:
        0: birim <OBJECT>   1: terminal / saha cihazı <OBJECT>   2: telsiz durumu <ARRAY>

    Dönüş: yok (yanıt: medOnData)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_medOnData", [_code, 1, false, []]] call TC2_fnc_netToUnit;
};

private _level = [_unit, _terminal] call TC2_fnc_accessLevel;
private _mode = _entry param [9, "DESK"];
private _canWrite = _level >= 2 && {!(_mode isEqualTo "VIEW")};

if (!_canWrite) exitWith {
    [_unit, "TC2_fnc_medOnData", ["OK", _level, false, []]] call TC2_fnc_netToUnit;
};

private _base = _entry select 4;
private _channel = _entry select 5;
private _range = [_base] call TC2_fnc_netRangeOf;
private _now = diag_tickTime;
private _viewerPos = getPosASL _unit;
private _myNet = netId _unit;

private _visible = (missionNamespace getVariable ["TC2_med_requests", []]) select {
    ((_x select 6) isEqualTo _base) && {(_x select 7) == _channel} && {(_now - (_x select 5)) < 3600} && {
        private _sender = _x select 2;
        private _reference = if (!isNull _sender && {alive _sender}) then {getPosASL _sender} else {_x select 12};
        (_viewerPos distance _reference) <= _range
    }
};
_visible = _visible select [(count _visible - 8) max 0, 8];

private _summary = _visible apply {
    _x params ["_id", "_senderNet", "", "_callsign", "_data", "_time", "", "", "_status", "", "_acceptor", "_eta", "_position"];
    [_id, _callsign, round (_now - _time), _status, _acceptor, _eta, _senderNet isEqualTo _myNet, [_data, [[_position] call TC2_fnc_casGrid, _callsign, format ["%1 K%2", _base, _channel]]] call TC2_fnc_medLines]
};
reverse _summary;

[_unit, "TC2_fnc_medOnData", ["OK", _level, true, _summary]] call TC2_fnc_netToUnit;
