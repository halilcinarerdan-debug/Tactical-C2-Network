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

// 5. Dijital 9-Line CAS
call TC2_fnc_casInitSettings;

// 5B. Topcu (CFF / FDC)
call TC2_fnc_artyInitSettings;

// 6. OPORD / belge yetki seviyeleri
call TC2_fnc_opordInitSettings;
