/*
    XEH_preInit.sqf
    TÜM makinelerde (sunucu, istemci, headless) mod yüklenince, mission başlamadan önce çalışır.

    Sunucu da CBA ayarlarını kaydetmek ZORUNDA: "global" ayarlar sunucudan istemcilere senkronlanır
    ve sunucu erişim kararını kendi ayar değerleriyle verir.
*/

// 1. Fiziksel terminal + erişim kontrolü
call TC2_fnc_terminalInitSettings;

// 3. ACRE2 veri agi
call TC2_fnc_netInitSettings;

// 4. Ortak harekat resmi
call TC2_fnc_copInitSettings;
