/*
    Fonksiyon: TC2_fnc_artyInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Topçu (CFF / FDC) CBA ayarları. Sunucu da kaydeder; kararlar sunucuda verilir.
*/

private _category = ["Tactical C2 Network", "Topçu (CFF / FDC)"];

[
    "TC2_arty_aiWest",
    "CHECKBOX",
    ["AI mürettebatlı toplar: BLUFOR (west)", "Açıksa FDC'nin atış emirleri BLUFOR'un AI mürettebatlı topları/havanları tarafından uygulanır. Kapalıysa AI'lı bataryalar kullanılamaz (oyuncu mürettebatlılar etkilenmez)."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TC2_arty_aiEast",
    "CHECKBOX",
    ["AI mürettebatlı toplar: OPFOR (east)", "Açıksa FDC'nin atış emirleri OPFOR'un AI mürettebatlı topları/havanları tarafından uygulanır. Kapalıysa AI'lı bataryalar kullanılamaz (oyuncu mürettebatlılar etkilenmez)."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TC2_arty_aiGuer",
    "CHECKBOX",
    ["AI mürettebatlı toplar: INDFOR (independent)", "Açıksa FDC'nin atış emirleri INDFOR'un AI mürettebatlı topları/havanları tarafından uygulanır."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TC2_arty_gunClasses",
    "EDITBOX",
    ["Ek top/havan sınıfları (classname)", "Otomatik tanıma (artillery computer'ı olan ya da StaticMortar sınıfından türeyen araçlar) dışında topçu sayılacak mod sınıfları. ; veya , ile ayrılır."],
    _category,
    "",
    true
] call CBA_settings_fnc_init;

[
    "TC2_arty_allowSelf",
    "CHECKBOX",
    ["TEST: CFF'i kendine (FDC olarak) gönderebil", "Yalnızca TEST içindir. Açıksa gözlemci kendi FDC'sine CFF gönderebilir (tek başına test). Gerçek oyunda KAPALI olmalı."],
    _category,
    false,
    true
] call CBA_settings_fnc_init;
