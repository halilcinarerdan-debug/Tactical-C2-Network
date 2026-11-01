/*
    Fonksiyon: TC2_fnc_netInitSettings
    Çalışma yeri: TÜM makineler (XEH_preInit.sqf çağırır)

    Ağ (ACRE2) CBA ayarları. Sunucu da kaydeder; menzil kararını sunucu kendi değerleriyle verir.
*/

[
    "TC2_net_ranges",
    "EDITBOX",
    ["Telsiz menzil tablosu (metre)", "Biçim: TELSIZ_SINIFI:menzil,TELSIZ_SINIFI:menzil,...,default:menzil (virgülle ayırın; ';' ve '=' CBA ayar dosyasını (cba_settings.sqf) bozduğu için kullanılmaz, eski biçim de okunur). Terminaller arası mesaj yalnızca AYNI telsiz tipi ve AYNI kanalda, bu menzil içindeyse iletilir. Bu ACRE2'nin arazi modeli değil, sabit menzil tablosudur."],
    ["Tactical C2 Network", "Ağ (ACRE2)"],
    "ACRE_PRC343:500,ACRE_PRC148:5000,ACRE_PRC152:8000,ACRE_PRC117F:20000,ACRE_PRC77:15000,ACRE_BF888S:1500,ACRE_SEM52SL:3000,ACRE_SEM70:10000,default:3000",
    true
] call CBA_settings_fnc_init;
