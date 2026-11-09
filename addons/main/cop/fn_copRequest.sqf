/*
    Fonksiyon: TC2_fnc_copRequest
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_copRequest", 2]
                  - host / tek oyunculuda: copUiRequest doğrudan çağırır

    Terminal haritası için veri: izleyicinin ağındaki dostlar (copFriendsOf), aktif CAS / CFF / MEDEVAC noktaları, görebildiği düşman işaretleri
    (copMarkersFor) ve doğrulanmamış SALUTE noktaları. LACE (liderlerin birlik durumu) ve doğrulanmamış SALUTE yalnızca Level 2+ ve
    izleme modunda OLMAYAN oturumlara gider (bilgi güvenirliği: tabletli er yalnızca dost/düşman işaretlerini görür). Önce oturum doğrulanır (erişim: kart, 5 m, canlı; telsiz envanterde mi). Telsiz yoksa
    veya ağ yoksa boş veri + neden kodu döner.

    Parametreler:
        0: birim <OBJECT>
        1: terminal <OBJECT>
        2: telsiz durumu <ARRAY>

    Dönüş: yok (yanıt: copOnData)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_copOnData", [_code, [], [], [], []]] call TC2_fnc_netToUnit;
};

private _base = _entry select 4;
private _channel = _entry select 5;
private _now = diag_tickTime;

private _detail = ([_unit, _terminal] call TC2_fnc_accessLevel) >= 2 && {!((_entry param [9, "DESK"]) isEqualTo "VIEW")};
private _friends = [_unit, _base, _channel, _detail] call TC2_fnc_copFriendsOf;
private _markers = ([_base, _channel, _unit] call TC2_fnc_copMarkersFor) apply {
    [_x select 0, _x select 1, _x select 2, _x select 5, round (_now - (_x select 7))]
};

// Doğrulanmamış SALUTE noktaları: [id, konum ASL, yaş sn, çağrı adı]
private _unverified = [];
if (_detail) then {
    private _range = [_base] call TC2_fnc_netRangeOf;
    private _viewerPos = getPosASL _unit;
    {
        _x params ["_id", "_type", "", "_callsign", "", "_time", "_rBase", "_rChannel", "_verified", "_position", "", "", "_sender"];
        if (_type isEqualTo "SALUTE" && {!_verified} && {_rBase isEqualTo _base} && {_rChannel == _channel} && {(_now - _time) < 1800}) then {
            private _reference = if (!isNull _sender && {alive _sender}) then {getPosASL _sender} else {_position};
            if ((_viewerPos distance _reference) <= _range) then {
                _unverified pushBack [_id, _position apply {round _x}, round (_now - _time), _callsign];
            };
        };
    } forEach (missionNamespace getVariable ["TC2_reports", []]);
};

// Aktif ateş destek / tahliye noktaları (CAS hedefi, CFF hedefi, MEDEVAC alım yeri): [tür, id, konum ASL, etiket, yaş sn]
private _ops = [];
if (_detail) then {
    {
        // CAS: [id, jtacNet, jtac, pilotNet, pilot, data, platform, durum, sonuçlar, zaman, ağ, kanal, ...]
        if ((_x select 10) isEqualTo _base && {(_x select 11) == _channel} && {!((_x select 7) isEqualTo "ABORTED")} && {(_now - (_x select 9)) < 1800}) then {
            private _data = _x select 5;
            private _mark = _data select 9;
            _ops pushBack ["CAS", _x select 0, (_data select 8) apply {round _x}, format ["CAS #%1%2", _x select 0, [format ["  %1", _mark], format ["  LAZER %1", _data select 10]] select (_mark isEqualTo "LASER")], round (_now - (_x select 9))];
        };
    } forEach (missionNamespace getVariable ["TC2_cas_requests", []]);
    {
        // CFF: [id, ..., 7 durum, ..., 10 hedef konumu, ..., 15 zaman, 16 ağ, 17 kanal]
        if ((_x select 16) isEqualTo _base && {(_x select 17) == _channel} && {!((_x select 7) in ["EOM", "REJECTED", "CANCELLED"])} && {(_now - (_x select 15)) < 3600}) then {
            _ops pushBack ["CFF", _x select 0, (_x select 10) apply {round _x}, format ["CFF #%1", _x select 0], round (_now - (_x select 15))];
        };
    } forEach (missionNamespace getVariable ["TC2_arty_missions", []]);
    {
        // MEDEVAC: [id, ..., 5 zaman, 6 ağ, 7 kanal, 8 durum, ..., 12 konum]
        if ((_x select 6) isEqualTo _base && {(_x select 7) == _channel} && {(_x select 8) in ["OPEN", "ACCEPTED"]} && {(_now - (_x select 5)) < 3600}) then {
            _ops pushBack ["MED", _x select 0, (_x select 12) apply {round _x}, format ["MEDEVAC #%1", _x select 0], round (_now - (_x select 5))];
        };
    } forEach (missionNamespace getVariable ["TC2_med_requests", []]);
};

[_unit, "TC2_fnc_copOnData", ["OK", _friends, _markers, _unverified, _ops]] call TC2_fnc_netToUnit;
