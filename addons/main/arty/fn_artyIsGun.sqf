/*
    Fonksiyon: TC2_fnc_artyIsGun
    Çalışma yeri: SADECE SUNUCU (saf)

    Araç dolaylı ateş silahı mı? Otomatik tanıma: artillery computer'ı olan (`artilleryScanner` > 0) ya da `StaticMortar`
    sınıfından türeyen araçlar, ayrıca CBA ayarındaki "Ek top/havan sınıfları".

    Parametreler:
        0: araç <OBJECT>

    Dönüş: <BOOL>
*/

params [["_vehicle", objNull, [objNull]]];

if (isNull _vehicle || {_vehicle isKindOf "CAManBase"} || {!(_vehicle isKindOf "AllVehicles")}) exitWith {false};

private _extra = ((missionNamespace getVariable ["TC2_arty_gunClasses", ""]) splitString ";, ") apply {toLower _x};

(getNumber (configFile >> "CfgVehicles" >> typeOf _vehicle >> "artilleryScanner") > 0)
|| {_vehicle isKindOf "StaticMortar"}
|| {(toLower (typeOf _vehicle)) in _extra}
