/*
    Fonksiyon: TC2_fnc_copRequest
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_copRequest", 2]
                  - host / tek oyunculuda: copUiRequest doğrudan çağırır

    Terminal haritası için veri: izleyicinin ağındaki dostlar (copFriendsOf), görebildiği düşman işaretleri
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
    [_unit, "TC2_fnc_copOnData", [_code, [], [], []]] call TC2_fnc_netToUnit;
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

[_unit, "TC2_fnc_copOnData", ["OK", _friends, _markers, _unverified]] call TC2_fnc_netToUnit;
