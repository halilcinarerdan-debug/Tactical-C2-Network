/*
    Fonksiyon: TC2_fnc_casInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Aşama 5 (9-Line CAS) CBA ayarları. Sunucu da kaydeder; kararlar sunucuda verilir.
*/

[
    "TC2_cas_jtacClasses",
    "EDITBOX",
    ["JTAC sınıfları (classname)", "Bu sınıftaki askerler JTAC sayılır. Virgülle ayırın (';' cba_settings.sqf dosyasını bozar). Bir askere Zeus modülüyle JTAC verilmesi/alınması bu listeyi geçersiz kılar. Ayrıca Eden'de rol açıklamasında JTAC veya FAC yazanlar da JTAC sayılır."],
    ["Tactical C2 Network", "Joint Fires (9-Line CAS)"],
    "B_recon_JTAC_F,O_recon_JTAC_F",
    true
] call CBA_settings_fnc_init;

[
    "TC2_arty_observerClasses",
    "EDITBOX",
    ["Gözlemci (FO/JFO) sınıfları (classname)", "Bu sınıftaki askerler topçu gözlemcisi sayılır. ; veya , ile ayrılır. Zeus modülüyle verilen/alınan yetki bu listeyi geçersiz kılar. Eden rol açıklamasında FO, JFO, FIST veya OBSERVER yazanlar da gözlemci sayılır."],
    ["Tactical C2 Network", "Topçu (CFF / FDC)"],
    "",
    true
] call CBA_settings_fnc_init;

[
    "TC2_arty_fdcClasses",
    "EDITBOX",
    ["FDC operatörü sınıfları (classname)", "Bu sınıftaki askerler FDC operatörü sayılır. Zeus modülüyle verilen/alınan yetki bu listeyi geçersiz kılar. Eden rol açıklamasında FDC veya FDO yazanlar da FDC sayılır."],
    ["Tactical C2 Network", "Topçu (CFF / FDC)"],
    "",
    true
] call CBA_settings_fnc_init;

[
    "TC2_cas_allowSelf",
    "CHECKBOX",
    ["TEST: 9-Line'ı kendine gönderebil", "Yalnızca TEST içindir. Açıksa JTAC, 9-Line'ı kendi kendine 'pilot' olarak gönderebilir (tek başına test). Gerçek oyunda KAPALI olmalı."],
    ["Tactical C2 Network", "Joint Fires (9-Line CAS)"],
    false,
    true
] call CBA_settings_fnc_init;
