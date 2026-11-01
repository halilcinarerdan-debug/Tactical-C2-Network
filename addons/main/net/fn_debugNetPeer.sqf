/*
    Fonksiyon: TC2_fnc_debugNetPeer
    Çalışma yeri: SADECE SUNUCU (debug konsolunda "Server Exec"; host'ta "Local Exec" da olur)

    TEST YARDIMCISI: yanında ikinci oyuncu olmadan ağı denemek için bir AI birimini "simüle terminal eşi"
    yapar. Eş, verilen telsiz tipi ve kanalda ağdadır; mesafesi ve kanalı gerçek kurallarla denetlenir.
    PING'e sunucu PONG döner, MSG sunucu RPT'sine yazılır ("[TC2][NET] SIM-ES ...").

    Parametreler:
        0: eş olacak birim <OBJECT>
        1: telsiz tipi <STRING>  (varsayılan "ACRE_PRC343")
        2: kanal <NUMBER>        (varsayılan 1)
        3: aç/kapat <BOOL>       true = ekle (varsayılan), false = kaldır

    Dönüş: başarılı mı <BOOL>

    Örnek (host, Local Exec):
        TC2_p = (createGroup west) createUnit ["B_Soldier_F", player getPos [300, 0], [], 0, "NONE"];
        [TC2_p, "ACRE_PRC343", 1, true] call TC2_fnc_debugNetPeer;
*/

if (!isServer) exitWith {false};

params [["_unit", objNull, [objNull]], ["_base", "ACRE_PRC343", [""]], ["_channel", 1, [0]], ["_enable", true, [true]]];

if (isNull _unit) exitWith {false};

private _netId = netId _unit;
private _sessions = (missionNamespace getVariable ["TC2_net_sessions", []]) select {(_x select 0) != _netId};

if (_enable) then {
    private _label = [format ["SIM-%1", name _unit], 30] call TC2_fnc_netSanitize;
    _sessions pushBack [_netId, _unit, _label, "SIM_RADIO", _base, _channel, diag_tickTime, true, 0];
};

missionNamespace setVariable ["TC2_net_sessions", _sessions];
diag_log format ["[TC2][NET] debugNetPeer %1 birim=%2 tip=%3 kanal=%4", if (_enable) then {"EKLENDI"} else {"KALDIRILDI"}, name _unit, _base, _channel];

true
