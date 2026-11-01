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
    "TC2_cop_showAi",
    "CHECKBOX",
    ["AI grup liderlerini haritada göster", "Açıksa, envanterinde saha tableti olan AI GRUP LİDERLERİ aynı taraftaki terminal / saha cihazı haritasında dost simgesi olarak görünür (oyuncularla aynı telsiz menzili kuralı; LACE sayıları sistemden okunur). AI'ya tablet vermek için Eden'de başlatma alanına: this addItem 'TC2_Tablet'"],
    _category,
    true,
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
