/*
    Fonksiyon: TC2_fnc_rptPoll
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_rptPoll", 2]
                  - host / tek oyunculuda: rptUiRequest doğrudan çağırır

    RAPOR sekmesinin verisi. Yalnızca Level 2 ve üstü (Mavi kart / lider / kurmay) raporları görür; Level 1 (Kırmızı kart) ve izleme
    modundaki er HİÇ rapor görmez (bilgi güvenirliği + OPSEC). Rapor, izleyen ile AYNI telsiz ağında (tip + kanal) ve göndericinin
    (güncel konumunun) telsiz menzili içindeyse görünür. Yanıt: kod, seviye, yazabilir mi, doğrulayabilir mi, son 12 rapor özeti
    [id, tür, gönderen, yaş sn, doğrulandı mı, satırlar].

    Parametreler:
        0: birim <OBJECT>   1: terminal / saha cihazı <OBJECT>   2: telsiz durumu <ARRAY>

    Dönüş: yok (yanıt: rptOnData)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_rptOnData", [_code, 1, false, false, []]] call TC2_fnc_netToUnit;
};

private _level = [_unit, _terminal] call TC2_fnc_accessLevel;
private _mode = _entry param [9, "DESK"];
private _canWrite = _level >= 2 && {!(_mode isEqualTo "VIEW")};
private _canVerify = _level >= 2 && {[_unit, "S2"] call TC2_fnc_hasRole || {[_unit, "CO"] call TC2_fnc_hasRole}};

if (_level < 2 || {_mode isEqualTo "VIEW"}) exitWith {
    [_unit, "TC2_fnc_rptOnData", ["OK", _level, false, false, []]] call TC2_fnc_netToUnit;
};

private _base = _entry select 4;
private _channel = _entry select 5;
private _range = [_base] call TC2_fnc_netRangeOf;
private _now = diag_tickTime;
private _viewerPos = getPosASL _unit;

private _visible = (missionNamespace getVariable ["TC2_reports", []]) select {
    ((_x select 6) isEqualTo _base) && {(_x select 7) == _channel} && {
        private _sender = _x select 12;
        private _reference = if (!isNull _sender && {alive _sender}) then {getPosASL _sender} else {_x select 9};
        (_viewerPos distance _reference) <= _range
    }
};
_visible = _visible select [(count _visible - 12) max 0, 12];

private _summary = _visible apply {
    _x params ["_id", "_type", "", "_callsign", "_data", "_time", "", "", "_verified", "_position", "", "_auto"];
    [_id, _type, _callsign, round (_now - _time), _verified, [_type, _data, [[_position] call TC2_fnc_casGrid, _auto]] call TC2_fnc_rptLines]
};
reverse _summary;

[_unit, "TC2_fnc_rptOnData", ["OK", _level, _canWrite, _canVerify, _summary]] call TC2_fnc_netToUnit;
