/*
    Fonksiyon: TC2_fnc_virtInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    SANAL ATEŞ DESTEĞİ (isteğe bağlı) CBA ayarları. Sunucu da kaydeder; sanal destek sunucuda çalışır.
    Açıkken, oyuncular CAS 9-Line / CFF formunu DOĞRU doldurup gönderince (gerçek pilot / FDC / batarya olmasa bile) yapay zekâ uçağı gelip vurur ya da
    sanal batarya mermi yağdırır.
*/

private _category = ["Tactical C2 Network", "Sanal ateş desteği"];

[
    "TC2_virt_cas",
    "CHECKBOX",
    ["Sanal CAS (yapay uçak)", "Açıksa JTAC'ın alıcı listesine 'SANAL CAS (yapay)' eklenir. 9-Line doğru doldurulup geri okuma tamamlanınca uçak kalkış gecikmesinden sonra gelir, atak yönünden girer, topla / roketle / bombayla vurur ve çıkar."],
    _category,
    false,
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_casClassWest",
    "EDITBOX",
    ["Sanal CAS uçağı: BLUFOR (classname)", "Sabit kanatlı saldırı uçağı sınıfı. Varsayılan: B_Plane_CAS_01_dynamicLoadout_F (A-164 Wipeout). Uçağın kendi silahları kullanılır (top, roket, bomba, füze)."],
    _category,
    "B_Plane_CAS_01_dynamicLoadout_F",
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_casClassEast",
    "EDITBOX",
    ["Sanal CAS uçağı: OPFOR (classname)", "Varsayılan: O_Plane_CAS_02_dynamicLoadout_F (To-199 Neophron)."],
    _category,
    "O_Plane_CAS_02_dynamicLoadout_F",
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_casClassGuer",
    "EDITBOX",
    ["Sanal CAS uçağı: INDFOR (classname)", "Varsayılan: I_Plane_Fighter_03_dynamicLoadout_F (A-143 Buzzard)."],
    _category,
    "I_Plane_Fighter_03_dynamicLoadout_F",
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_casDelay",
    "SLIDER",
    ["Sanal CAS: kalkış / yaklaşma gecikmesi (sn)", "Geri okuma tamamlandıktan sonra uçağın sahaya gelmesine kadar geçen süre (gerçek uçak gelişi için)."],
    _category,
    [5, 300, 45, 0],
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_casCooldown",
    "SLIDER",
    ["Sanal CAS: yeniden dolum süresi (sn)", "Bir sortiden sonra aynı tarafın sanal CAS'ı bu süre boyunca meşguldür (yeniden silahlanma). 0 = yok."],
    _category,
    [0, 900, 120, 0],
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_arty",
    "CHECKBOX",
    ["Sanal topçu (yapay batarya)", "Açıksa FDC'nin batarya listesine 'SANAL BATARYA' eklenir (gerçek top / mürettebat gerekmez). FDC KABUL edince hazırlık gecikmesinden sonra mermiler uçuş süresiyle düşer: SHOT / SPLASH / ROUNDS COMPLETE otomatik."],
    _category,
    false,
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_artyAutoFdc",
    "CHECKBOX",
    ["Sanal FDC (FDC oyuncusu olmadan)", "Açıksa (ve sanal topçu açıkken) gözlemcinin FDC listesine 'SANAL FDC' eklenir: CFF'yi FDC oyuncusu olmadan hesaplayıp sanal bataryaya otomatik KABUL eder."],
    _category,
    true,
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_artyCaliber",
    "LIST",
    ["Sanal batarya kalibresi", "Mermi sınıfı ve uçuş süresi bu seçime göre belirlenir (82 mm havan ~18 sn, 120 mm ~24 sn, 155 mm ~32 sn)."],
    _category,
    [["82", "120", "155"], ["82 mm havan", "120 mm havan", "155 mm obüs"], 2],
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_artyGuns",
    "SLIDER",
    ["Sanal batarya: top sayısı", "Fire for effect'te atılan toplam mermi = istenen mermi (top başına) x top sayısı. Adjust fire'da tek mermi."],
    _category,
    [1, 8, 4, 0],
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_artyPrep",
    "SLIDER",
    ["Sanal topçu: hazırlık gecikmesi (sn)", "KABUL'den ilk mermiye (SHOT) kadar geçen süre (ateş hesabı, top yöneltme)."],
    _category,
    [3, 90, 15, 0],
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_artyRate",
    "SLIDER",
    ["Sanal topçu: mermi aralığı (sn)", "Ardışık mermiler arasındaki süre."],
    _category,
    [1, 15, 4, 0],
    true
] call CBA_settings_fnc_init;

[
    "TC2_virt_artyError",
    "SLIDER",
    ["Sanal topçu: isabet yayılımı (m)", "Her merminin hedef noktasından sapma yarıçapı (olası yayılma). Küçük = hassas."],
    _category,
    [0, 150, 25, 0],
    true
] call CBA_settings_fnc_init;
