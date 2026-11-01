/*
    Fonksiyon: TC2_fnc_debugNetInfo
    Çalışma yeri: SADECE SUNUCU (debug konsolunda "Server Exec"; sonuç konsolda görünür ve RPT'ye yazılır)

    TEST YARDIMCISI: sunucudaki ağ kayıtlarını ve aralarındaki mesafe/menzil ilişkisini listeler.
    "Neden bağlantı var/yok?" sorusunun cevabı burada: her oturum için telsiz tipi, kanal, simüle mi,
    kaç sn önce rapor etti ve her çift için gerçek mesafe ile geçerli menzil.

    Parametreler: yok
    Dönüş: satırlar <ARRAY of STRING>
*/

if (!isServer) exitWith {["yalnizca sunucuda"]};

private _sessions = missionNamespace getVariable ["TC2_net_sessions", []];
private _lines = [format ["TC2_net_ranges = '%1'", missionNamespace getVariable ["TC2_net_ranges", "(yok)"]], format ["oturum sayisi: %1", count _sessions]];

{
    private _a = _x;
    _lines pushBack format ["#%1 %2 | tip=%3 kanal=%4 | sim=%5 | rapor=%6 sn once | menzil=%7 m", _forEachIndex, _a select 2, _a select 4, _a select 5, _a select 7, round (diag_tickTime - (_a select 6)), [_a select 4] call TC2_fnc_netRangeOf];
    {
        private _b = _x;
        if ((_b select 0) != (_a select 0)) then {
            _lines pushBack format ["     -> %1 : mesafe=%2 m", _b select 2, round ((_a select 1) distance (_b select 1))];
        };
    } forEach _sessions;
} forEach _sessions;

{diag_log ("[TC2][NETINFO] " + _x)} forEach _lines;

_lines
