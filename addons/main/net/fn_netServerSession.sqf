/*
    Fonksiyon: TC2_fnc_netServerSession
    Çalışma yeri: SADECE SUNUCU

    Bir terminal oturumunu sunucu kaydına (TC2_net_sessions) ekler/günceller. Her kayıt:
        0 netId   1 birim   2 terminal kimliği   3 telsiz ID   4 telsiz taban sınıfı   5 kanal
        6 son rapor zamanı (diag_tickTime)   7 simüle mi (test)   8 son gönderim zamanı   9 kullanım modu (DESK | FIELD | VIEW)

    Doğrulamalar (istemciye güvenilmez):
      - Erişim hâlâ geçerli mi? (accessCheck: kart, 5 m, canlı, bilinçli) -> değilse kayıt SİLİNİR.
      - Telsiz gerçekten birimin envanterinde mi? (ACRE telsizleri benzersiz ID'li envanter eşyasıdır.)
        Değilse kayıt telsizsiz tutulur (ağa katılamaz).
      - KANAL istemcinin bildirdiği değerdir (sunucu başkasının ACRE durumunu okuyamaz) -> bilinen sınır.
      - Eski kayıtlar (15 sn rapor yok) temizlenir.

    Parametreler:
        0: birim <OBJECT>
        1: terminal <OBJECT>
        2: telsiz durumu <ARRAY> [var mı, telsiz ID, taban sınıf, kanal, neden]  (netGetRadioState)

    Dönüş: [başarılı <BOOL>, kod <STRING>, kayıt <ARRAY>]
        kod: "OK" | "NO_RADIO" | "NO_ACRE" | erişim ret nedeni (TOO_FAR, NO_CARD, DEAD ...)
*/

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]]];

private _now = diag_tickTime;
private _sessions = (missionNamespace getVariable ["TC2_net_sessions", []]) select {
    !isNull (_x select 1) && {(_x select 7) || {(_now - (_x select 6)) < 15}}
};

private _netId = netId _unit;
private _index = -1;
{
    if ((_x select 0) == _netId) exitWith {_index = _forEachIndex};
} forEach _sessions;

private _access = [_terminal, _unit] call TC2_fnc_accessCheck;

if !(_access select 0) exitWith {
    if (_index >= 0) then {_sessions deleteAt _index};
    missionNamespace setVariable ["TC2_net_sessions", _sessions];
    [false, _access select 1, []]
};

_state params [["_has", false, [false]], ["_radioId", "", [""]], ["_base", "", [""]], ["_channel", -1, [0]], ["_reason", "NO_RADIO", [""]]];

private _code = "OK";
if (_has) then {
    private _items = (items _unit) apply {toLower _x};
    if !((toLower _radioId) in _items) then {
        _has = false;
        _code = "NO_RADIO";
    };
} else {
    _code = if (_reason isEqualTo "NO_ACRE") then {"NO_ACRE"} else {"NO_RADIO"};
};

if (!_has) then {
    _radioId = "";
    _base = "";
    _channel = -1;
};

private _lastSend = 0;
if (_index >= 0) then {_lastSend = (_sessions select _index) select 8};

// 9: kullanım modu (DESK | FIELD | VIEW). VIEW (er, yalnızca izleme) yazma işlemlerinde sunucuda reddedilir.
private _entry = [_netId, _unit, [_terminal] call TC2_fnc_terminalGetId, _radioId, _base, _channel, _now, false, _lastSend, [_unit, _terminal] call TC2_fnc_accessMode];

if (_index >= 0) then {
    _sessions set [_index, _entry];
} else {
    _sessions pushBack _entry;
};
missionNamespace setVariable ["TC2_net_sessions", _sessions];

[true, _code, _entry]
