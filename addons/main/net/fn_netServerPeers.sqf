/*
    Fonksiyon: TC2_fnc_netServerPeers
    Çalışma yeri: SADECE SUNUCU (saf: yalnızca okur)

    Bir oturumun ulaşabildiği DİĞER oturumları verir. Koşullar (hepsi):
      - ikisinin de telsizi var,
      - AYNI telsiz tipi ve AYNI kanal ("aynı kanal = aynı ağ"),
      - karşı taraf canlı ve kaydı taze (15 sn) ya da simüle test eşi,
      - birimler arası mesafe <= telsiz menzili (TC2_fnc_netRangeOf).

    Parametreler:
        0: oturum kaydı <ARRAY>  (netServerSession'ın döndürdüğü)

    Dönüş: eş kayıtları <ARRAY of ARRAY>
*/

params [["_self", [], [[]]]];

if (_self isEqualTo []) exitWith {[]};

_self params ["_netId", "_unit", "", "_radioId", "_base", "_channel"];

if (_radioId isEqualTo "") exitWith {[]};

private _now = diag_tickTime;
private _range = [_base] call TC2_fnc_netRangeOf;

(missionNamespace getVariable ["TC2_net_sessions", []]) select {
    (_x select 0) != _netId
    && {!((_x select 3) isEqualTo "")}
    && {(_x select 4) isEqualTo _base}
    && {(_x select 5) == _channel}
    && {(_x select 7) || {(_now - (_x select 6)) < 15}}
    && {alive (_x select 1)}
    && {(_unit distance (_x select 1)) <= _range}
}
