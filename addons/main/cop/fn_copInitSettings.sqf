/*
    Fonksiyon: TC2_fnc_copInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Aşama 4 (ortak harekat resmi) CBA ayarları. Sunucu da kaydeder; kararlar sunucuda verilir.
*/

private _category = ["Tactical C2 Network", "Ortak Harekat Resmi (COP)"];

[
    "TC2_cop_markerTtl",
    "SLIDER",
    ["İşaret ömrü (dakika)", "Haritaya konan düşman işaretleri bu süre sonunda otomatik silinir."],
    _category,
    [1, 240, 30, 0],
    true
] call CBA_settings_fnc_init;

[
    "TC2_cop_dagrEnabled",
    "CHECKBOX",
    ["MicroDAGR'a işaret gönder", "Açıksa, ağdaki GRUP LİDERLERİNİN ACE MicroDAGR cihazına düşman işaretleri waypoint olarak yazılır ('TC2 ...' adlı). Normal Arma haritasında görünmez."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;
