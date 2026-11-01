/*
    Fonksiyon: TC2_fnc_copMeasureText
    Çalışma yeri: İstemci (saf fonksiyon)

    Ölçüm sonucu: A noktasından B noktasına mesafe, yön (derece ve mil) ve yükseklik farkı.
    Yön: A'dan B'ye, kuzeyden saat yönünde (Arma kuzey = 0). Mil: NATO, tam daire 6400.

    Parametreler:
        0: A <ARRAY>   1: B <ARRAY>

    Dönüş: <STRING>
*/

params [["_a", [0, 0, 0], [[]]], ["_b", [0, 0, 0], [[]]]];

private _distance = _a distance2D _b;
private _bearing = round (_a getDir _b);
private _delta = round ((getTerrainHeightASL _b) - (getTerrainHeightASL _a));

format [
    "  ÖLÇÜM  %1   %2° / %3 mil   Δyük %4%5 m",
    [format ["%1 m", round _distance], format ["%1 km", (round (_distance / 10)) / 100]] select (_distance >= 2000),
    _bearing, round (_bearing * 6400 / 360),
    ["", "+"] select (_delta > 0), _delta
]
