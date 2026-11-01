/*
    Fonksiyon: TC2_fnc_copHeading
    Çalışma yeri: Her makine (saf fonksiyon)

    Bir askerin "baktığı yön" (derece, 0 = kuzey, saat yönü, 5 dereceye yuvarlanmış): yaya iken gözün baktığı yön (eyeDirection),
    araçtayken aracın yönü. Araçtaki gözün başı döndürmesi oku titretmesin diye araçta araç yönü alınır.

    Parametreler:
        0: asker <OBJECT>

    Dönüş: 0-355 <NUMBER>
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {0};

private _vehicle = vehicle _unit;
private _heading = if (_vehicle isEqualTo _unit) then {
    private _eye = eyeDirection _unit;
    (_eye select 0) atan2 (_eye select 1)
} else {
    getDir _vehicle
};

((round (_heading / 5)) * 5 + 360) mod 360
