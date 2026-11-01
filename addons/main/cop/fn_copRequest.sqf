/*
    Fonksiyon: TC2_fnc_copRequest
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_copRequest", 2]
                  - host / tek oyunculuda: copUiRequest doğrudan çağırır

    Terminal haritası için veri: izleyicinin ağındaki dostlar (copFriendsOf) ve görebildiği düşman işaretleri
    (copMarkersFor). Önce oturum doğrulanır (erişim: kart, 5 m, canlı; telsiz envanterde mi). Telsiz yoksa
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
    [_unit, "TC2_fnc_copOnData", [_code, [], []]] call TC2_fnc_netToUnit;
};

private _base = _entry select 4;
private _channel = _entry select 5;
private _now = diag_tickTime;

private _friends = [_unit, _base, _channel] call TC2_fnc_copFriendsOf;
private _markers = ([_base, _channel, _unit] call TC2_fnc_copMarkersFor) apply {
    [_x select 0, _x select 1, _x select 2, _x select 5, round (_now - (_x select 7))]
};

[_unit, "TC2_fnc_copOnData", ["OK", _friends, _markers]] call TC2_fnc_netToUnit;
