/*
    Fonksiyon: TC2_fnc_debugCard
    Çalışma yeri: İstemci / birimin yerel olduğu makine (debug konsolu "Local Exec")

    TEST YARDIMCISI: kimlik kartını birime verir veya alır. Kart sınıfı, TC2_access_cardClasses
    ayarındaki adaylardan CfgWeapons'ta GERÇEKTEN bulunan ilkidir ('Item_CAC_Card' bulunamazsa
    ön eksiz 'CAC_Card' denenir; bkz. TC2_fnc_accessGetCardClasses).

    Parametreler:
        0: birim <OBJECT>  (varsayılan: player)
        1: ver mi? <BOOL>  true = ver (varsayılan), false = al

    Dönüş: işlem başarılı mı <BOOL>

    Örnekler:
        [player, true] call TC2_fnc_debugCard;    // kartı ver
        [player, false] call TC2_fnc_debugCard;   // kartı geri al
*/

params [["_unit", player, [objNull]], ["_give", true, [true]]];

if (isNull _unit) exitWith {false};

// Adaylardan envanterde gerçekten bir eşya olan ilk sınıfı bul.
private _inventoryClass = "";
{
    if (isClass (configFile >> "CfgWeapons" >> _x)) exitWith {_inventoryClass = _x};
} forEach ([] call TC2_fnc_accessGetCardClasses);

if (_inventoryClass isEqualTo "") exitWith {
    ["Kart sınıfı CfgWeapons içinde bulunamadı (mod yüklü mü?). Ayrıntı için: [] call TC2_fnc_debugInfo", "error"] call TC2_fnc_notify;
    false
};

private _ok = false;
if (_give) then {
    if (_unit canAdd _inventoryClass) then {
        _unit addItem _inventoryClass;
        _ok = true;
        [format ["Kart verildi: %1", _inventoryClass], "success"] call TC2_fnc_notify;
    } else {
        ["Envanterde kart için yer yok.", "error"] call TC2_fnc_notify;
    };
} else {
    _unit removeItem _inventoryClass;
    _ok = true;
    [format ["Kart alındı: %1", _inventoryClass], "info"] call TC2_fnc_notify;
};

_ok
