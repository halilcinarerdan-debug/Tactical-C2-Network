/*
    XEH_postInit.sqf
    Mission başlarken, objeler oluşturulduktan sonra çalışır (JIP dahil).
    Bu dosya initPlayerLocal.sqf'in addon karşılığıdır; mission dosyasına
    hiçbir şey eklemek gerekmez.

    Sunucuda yapılacak ek bir kurulum yok: sunucu tarafı fonksiyonlar (TC2_fnc_accessServerHandle vb.)
    CfgFunctions ile zaten derlenmiş durumdadır ve remoteExec ile çağrılır.
*/

// OPORD: sunucu, mission klasöründeki tc2_opord.sqf varsa yayımlar (arayüzü olmayan sunucuda da çalışır).
if (isServer) then {call TC2_fnc_opordLoad};

// ACE menüsü ve bildirimler yalnızca arayüzü olan makinelerde anlamlı.
if (!hasInterface) exitWith {};

// 1. Fiziksel terminal + erişim kontrolü
call TC2_fnc_terminalPostInit;

// 4. Ortak harekat resmi: saha varlığı bildirimi (10 sn)
call TC2_fnc_copPostInit;

// 5. Dijital 9-Line CAS: pilot tarafı (ACE self menü eylemi)
call TC2_fnc_casPostInit;
