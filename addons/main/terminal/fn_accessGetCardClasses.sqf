/*
    Fonksiyon: TC2_fnc_accessGetCardClasses
    Çalışma yeri: Her makine

    TC2_access_cardClasses ayarını çözer ve KÜÇÜK HARFLİ aday sınıf listesi verir.

    'Item_' ön eki hakkında: Arma'da `Item_Xyz`, yere bırakılan eşyanın CfgVehicles sınıfıdır
    (WeaponHolder). Envanterde duran gerçek eşya ise çoğunlukla CfgWeapons'taki ön eksiz `Xyz`'dir.
    Ayarda `Item_CAC_Card` yazılsa bile hem `item_cac_card` hem `cac_card` kabul edilir; böylece
    hangi adın gerçek envanter sınıfı olduğunu bilmeden de doğru çalışır. (Gerçek sınıfı görmek için:
    [] call TC2_fnc_debugInfo)

    Parametreler: yok
    Dönüş: <ARRAY of STRING> küçük harfli sınıf adları (ayar boşsa boş dizi)
*/

private _raw = missionNamespace getVariable ["TC2_access_cardClasses", "Item_CAC_Card"];
private _classes = [];

{
    private _class = toLower _x;
    if (_class != "") then {
        _classes pushBackUnique _class;
        if ((_class find "item_") == 0 && {count _class > 5}) then {
            _classes pushBackUnique (_class select [5, (count _class) - 5]);
        };
    };
} forEach (_raw splitString ",; ");

_classes
