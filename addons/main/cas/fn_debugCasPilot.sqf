/*
    Fonksiyon: TC2_fnc_debugCasPilot
    Çalışma yeri: SADECE SUNUCU (debug konsolunda "Server Exec"; host'ta "Local Exec" da olur)

    TEST YARDIMCISI: ikinci oyuncu olmadan 9-Line'ı denemek için bir AI birimini "simüle CAS pilotu" yapar.
    JTAC'ın alıcı listesinde (menzil + aynı tip/kanal kurallarıyla) görünür; 9-Line gelince 3 sn sonra geri okur.
    "yanlış" açıksa konumu bilerek yanlış okur (JTAC'ın hata gösterimini denemek için).

    Parametreler:
        0: birim <OBJECT>
        1: telsiz tipi <STRING>   (varsayılan "ACRE_PRC343")
        2: kanal <NUMBER>         (varsayılan 1)
        3: platform <STRING>      "FW" | "RW" (varsayılan "RW")
        4: yanlış okusun mu <BOOL> (varsayılan false)
        5: aç/kapat <BOOL>        true = ekle (varsayılan), false = kaldır

    Dönüş: başarılı mı <BOOL>

    Örnek (host, Local Exec):
        TC2_pilot = (createGroup west) createUnit ["B_Soldier_F", player getPos [200, 0], [], 0, "NONE"];
        [TC2_pilot, "ACRE_PRC343", 1, "RW", false] call TC2_fnc_debugCasPilot;
*/

if (!isServer) exitWith {false};

params [
    ["_unit", objNull, [objNull]], ["_base", "ACRE_PRC343", [""]], ["_channel", 1, [0]],
    ["_platform", "RW", [""]], ["_wrong", false, [false]], ["_enable", true, [true]]
];

if (isNull _unit) exitWith {false};

private _netId = netId _unit;
private _pilots = (missionNamespace getVariable ["TC2_cas_simPilots", []]) select {(_x select 0) != _netId};

if (_enable) then {
    private _label = [format ["SIM-PILOT %1", name _unit], 30] call TC2_fnc_netSanitize;
    _pilots pushBack [_netId, _unit, _base, _channel, _platform, _wrong, _label];
};

missionNamespace setVariable ["TC2_cas_simPilots", _pilots];
diag_log format ["[TC2][CAS] debugCasPilot %1 birim=%2 tip=%3 kanal=%4 platform=%5 yanlis=%6", if (_enable) then {"EKLENDI"} else {"KALDIRILDI"}, name _unit, _base, _channel, _platform, _wrong];

true
