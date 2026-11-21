/*
    Fonksiyon: TC2_fnc_camInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    KAMERA sekmesi (İHA + kask kamerası; yalnızca İZLEME) CBA ayarları. Sunucu da kaydeder; kaynak listesini sunucu üretir.
*/

private _category = ["Tactical C2 Network", "Kamera (İHA / kask)"];

[
    "TC2_cam_uavShare",
    "CHECKBOX",
    ["Dost İHA'ların kamerası izlenebilsin", "Açıksa Level 2+ kullanıcılar (izleme modunda olmayan) aynı taraftaki İHA'ların kamerasını terminalden / saha cihazından İZLEYEBİLİR (kontrol edemez). Tek bir İHA'yı gizlemek için objesine: this setVariable ['TC2_camHidden', true, true]"],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TC2_cam_helmetItem",
    "EDITBOX",
    ["Kask kamerası eşyası (classname)", "Envanterinde bu eşya olan askerin kask kamerası izlenebilir. Boşsa kask kamerası kapalıdır. Varsayılan: TC2_HelmetCam (eşya: 'TC2 Kask Kamerası')."],
    _category,
    "TC2_HelmetCam",
    true
] call CBA_settings_fnc_init;

[
    "TC2_cam_helmetRange",
    "CHECKBOX",
    ["Kask kamerası telsiz menziliyle sınırlı", "Açıksa kask kamerası yalnızca izleyenin telsiz tipinin menzili içindeyse görünür (COP dostlarıyla aynı kural). Kapalıysa taraftaki tüm kask kameraları görünür."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;
