/*
    Fonksiyon: TC2_fnc_casInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Aşama 5 (9-Line CAS) CBA ayarları. Sunucu da kaydeder; kararlar sunucuda verilir.
*/

[
    "TC2_cas_allowSelf",
    "CHECKBOX",
    ["TEST: 9-Line'ı kendine gönderebil", "Yalnızca TEST içindir. Açıksa JTAC, 9-Line'ı kendi kendine 'pilot' olarak gönderebilir (tek başına test). Gerçek oyunda KAPALI olmalı."],
    ["Tactical C2 Network", "Joint Fires (9-Line CAS)"],
    false,
    true
] call CBA_settings_fnc_init;
