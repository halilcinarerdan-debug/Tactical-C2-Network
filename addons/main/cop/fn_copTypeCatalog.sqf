/*
    Fonksiyon: TC2_fnc_copTypeCatalog
    Çalışma yeri: Her makine (saf fonksiyon; tek doğruluk kaynağı)

    Düşman işaretlerinin katalogu: kategoriler ve türler. Semboller oyunun kendi NATO harita simgeleridir (\A3\ui_f\data\map\markers\nato\o_*.paa,
    düşman = "o_" öneki; MIL-STD-2525 tarzı çerçeve). Tehlike türleri oyunun askeri işaret setindendir.
    Yeni tür eklemek için yalnızca bu listeye satır eklenir (sunucu doğrulaması, çizim, adlar ve seçim listeleri buradan beslenir).

    Dönüş: [[kategori adı, [[kod, ad, simge yolu, simge boyutu]]]] <ARRAY>
*/

private _nato = "\A3\ui_f\data\map\markers\nato\";
private _mil = "\A3\ui_f\data\map\markers\military\";

[
    ["PİYADE", [
        ["INF",    "DÜŞMAN PİYADE",              _nato + "o_inf.paa", 26],
        ["RECON",  "DÜŞMAN KEŞİF",               _nato + "o_recon.paa", 26],
        ["MOT",    "DÜŞMAN MOTORİZE PİYADE",     _nato + "o_motor_inf.paa", 26],
        ["MECH",   "DÜŞMAN MEKANİZE PİYADE",     _nato + "o_mech_inf.paa", 26]
    ]],
    ["ZIRH", [
        ["ARM",    "DÜŞMAN ZIRHLI / TANK",       _nato + "o_armor.paa", 28]
    ]],
    ["ATEŞ DESTEK", [
        ["ART",    "DÜŞMAN TOPÇU",               _nato + "o_art.paa", 28],
        ["MORT",   "DÜŞMAN HAVAN",               _nato + "o_mortar.paa", 26],
        ["AA",     "DÜŞMAN HAVA SAVUNMA",        _nato + "o_antiair.paa", 28]
    ]],
    ["HAVA", [
        ["HELI",   "DÜŞMAN HELİKOPTER",          _nato + "o_air.paa", 28],
        ["PLANE",  "DÜŞMAN UÇAK",                _nato + "o_plane.paa", 28],
        ["UAV",    "DÜŞMAN İHA",                 _nato + "o_uav.paa", 26]
    ]],
    ["KOMUTA / DESTEK", [
        ["HQ",     "DÜŞMAN KOMUTA YERİ",         _nato + "o_hq.paa", 28],
        ["SUP",    "DÜŞMAN İKMAL / DESTEK",      _nato + "o_support.paa", 26],
        ["MAINT",  "DÜŞMAN BAKIM",               _nato + "o_maint.paa", 26],
        ["SVC",    "DÜŞMAN HİZMET (SERVİS)",     _nato + "o_service.paa", 26],
        ["MED",    "DÜŞMAN SAĞLIK",              _nato + "o_med.paa", 26]
    ]],
    ["DENİZ / TESİS", [
        ["NAV",    "DÜŞMAN DENİZ ARACI",         _nato + "o_naval.paa", 28],
        ["INST",   "DÜŞMAN TESİS",               _nato + "o_installation.paa", 28]
    ]],
    ["TEHLİKE / DİĞER", [
        ["MINE",   "MAYIN / IED TEHLİKESİ",      _mil + "warning_CA.paa", 24],
        ["AMBUSH", "PUSU",                       _mil + "ambush_CA.paa", 24],
        ["UNK",    "BİLİNMEYEN TEMAS",           _nato + "o_unknown.paa", 26]
    ]]
]
