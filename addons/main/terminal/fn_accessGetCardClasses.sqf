/*
    Fonksiyon: TC2_fnc_accessGetCardClasses
    Çalışma yeri: Her makine

    Kabul edilen kart sınıflarını KÜÇÜK HARFLİ liste olarak verir:
      - projenin kendi kartı TC2_CAC_Card HER ZAMAN kabul edilir (CBA'nın kayıtlı eski bir ayar
        değeri bile bunu bozamaz),
      - TC2_access_cardClasses ayarındaki sınıflar EK olarak kabul edilir (harici moddan kart için).

    'Item_' ön eki hakkında: Arma'da `Item_Xyz`, yere bırakılan eşyanın CfgVehicles sınıfıdır
    (WeaponHolder). Envanterde duran gerçek eşya ise çoğunlukla CfgWeapons'taki ön eksiz `Xyz`'dir.
    Ayarda `Item_CAC_Card` yazılsa bile hem `item_cac_card` hem `cac_card` kabul edilir; böylece
    hangi adın gerçek envanter sınıfı olduğunu bilmeden de doğru çalışır. (Gerçek sınıfı görmek için:
    [] call TC2_fnc_debugInfo)

    Parametreler: yok
    Dönüş: <ARRAY of STRING> küçük harfli sınıf adları (en az "tc2_cac_card")
*/

private _raw = missionNamespace getVariable ["TC2_access_cardClasses", "Item_CAC_Card"];
private _classes = ["tc2_cac_card"];

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
