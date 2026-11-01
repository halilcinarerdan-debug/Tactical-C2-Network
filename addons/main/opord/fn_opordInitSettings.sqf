/*
    Fonksiyon: TC2_fnc_opordInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Belge yetki seviyeleri (Level 1/2/3) ve OPORD CBA ayarları. Sunucu da kaydeder; seviye kararı sunucuda verilir.
*/

private _category = ["Tactical C2 Network", "Belgeler ve Yetki (OPORD)"];

[
    "TC2_s4_level",
    "LIST",
    ["Lojistik Subayı (S4) seviyesi", "Masa başında S4'ün belge seviyesi. Bölük Komutanı (CO) ve İstihbarat Subayı (S2) her zaman Level 3'tür."],
    _category,
    [[2, 3], ["Level 2", "Level 3"], 0],
    true
] call CBA_settings_fnc_init;

[
    "TC2_desk_fires",
    "CHECKBOX",
    ["Masa başında Mavi+ kart 9-Line / CFF yazabilsin", "Açıksa masa başı terminalde Level 2 ve üstü (Mavi / Siyah-Altın kart ya da kurmay kadro) 9-Line ve CFF formlarını yazabilir (JTAC / gözlemci adına ateş destek hücresi). Kapalıysa yalnızca JTAC / gözlemci rolündekiler yazar."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TC2_level_rank2",
    "SLIDER",
    ["Level 2 için en düşük rütbe", "0 ER, 1 ONBAŞI, 2 ÇAVUŞ, 3 TEĞMEN, 4 ÜSTEĞMEN/YÜZBAŞI, 5 BİNBAŞI, 6 ALBAY (Arma rütbe sırası: PRIVATE..COLONEL). Grup liderleri ve JTAC / gözlemci / FDC rolündekiler rütbeden bağımsız Level 2 sayılır."],
    _category,
    [0, 6, 2, 0],
    true
] call CBA_settings_fnc_init;

[
    "TC2_level_rank3",
    "SLIDER",
    ["Level 3 için en düşük rütbe", "Level 3: komuta / kurmay. OPORD'u yalnızca Level 3 düzenler; en hassas bölümleri (haberleşme, frekanslar) yalnızca Level 3 görür. Zeus/Eden'de objede `TC2_level` (1-3) değişkeni rütbeyi geçersiz kılar."],
    _category,
    [0, 6, 3, 0],
    true
] call CBA_settings_fnc_init;
