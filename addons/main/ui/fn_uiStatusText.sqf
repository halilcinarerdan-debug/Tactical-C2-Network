/*
    Fonksiyon: TC2_fnc_uiStatusText
    Çalışma yeri: İstemci (uiOpen ve uiWatch; saniyede en çok 1 kez)

    Başlık çubuğundaki canlı durum satırı (ATAK'taki üst bar gibi): bakış yönü, saat, kendi konumunuzun grid'i, yükseklik.
    Yerel okuma, ağ yok.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

private _unit = ACE_player;
private _dir = round (getDir _unit);
private _names = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
private _name = _names select ((round (_dir / 45)) mod 8);

private _time = dayTime;
private _hh = floor _time;
private _mm = floor ((_time - _hh) * 60);

private _grid = mapGridPosition _unit;
private _half = floor ((count _grid) / 2);

private _text = format [
    "%1 %2°    %3:%4    %5 %6    YÜK %7 m",
    _name, _dir,
    [str _hh, "0" + str _hh] select (_hh < 10),
    [str _mm, "0" + str _mm] select (_mm < 10),
    _grid select [0, _half], _grid select [_half, _half],
    round ((getPosASL _unit) select 2)
];

(_display displayCtrl 92004) ctrlSetText _text;
