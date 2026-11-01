/*
    Fonksiyon: TC2_fnc_terminalInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    CBA ayarlarını CBA_settings_fnc_init ile kaydeder.
    Sunucu da kaydetmek ZORUNDA: "global" ayarlar sunucudan istemcilere senkronlanır,
    erişim kararını sunucu kendi ayar değerleriyle verir.

    Parametreler (CBA_settings_fnc_init, sırayla):
        0: ayar adı (global değişken adı olur)
        1: tür  - "CHECKBOX" | "SLIDER" | "EDITBOX" | "LIST" | "COLOR" | "TIME"
        2: [başlık, ipucu]
        3: [kategori, alt kategori]
        4: varsayılan değer (türe göre; SLIDER için [min, max, varsayılan, ondalık])
        5: isGlobal - true: sunucu ayarı, istemcilere senkron + force edilebilir
                      false: her oyuncunun kendi tercihi
*/

private _category = ["Tactical C2 Network", "Terminal ve Erişim (OPSEC)"];

[
    "TC2_terminal_enabled",
    "CHECKBOX",
    ["Terminal sistemi aktif", "Kapalıysa terminallerde ACE menüsü eylemi görünmez ve sunucu tüm erişim taleplerini reddeder."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TC2_access_cardClasses",
    "EDITBOX",
    ["Gerekli kimlik kartı (classname)", "Terminale girmek için envanterde/atanmış eşyalarda bulunması gereken eşya. Birden fazla sınıf ; veya , ile ayrılır. 'Item_' ön ekli yazılırsa ön eksiz hali de kabul edilir. BOŞ bırakılırsa kimse giremez."],
    _category,
    "Item_CAC_Card;TC2_CAC_Card",
    true
] call CBA_settings_fnc_init;

[
    "TC2_access_authTime",
    "SLIDER",
    ["Kimlik doğrulama süresi (sn)", "Kartı okutma ilerleme çubuğunun süresi. 0 = anında."],
    _category,
    [0, 10, 2, 1],
    true
] call CBA_settings_fnc_init;

[
    "TC2_debug",
    "CHECKBOX",
    ["Debug mesajları (bu istemci)", "Bildirimleri ayrıca sohbet satırına da yazar."],
    _category,
    false,
    false
] call CBA_settings_fnc_init;
