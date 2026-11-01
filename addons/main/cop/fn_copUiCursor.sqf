/*
    Fonksiyon: TC2_fnc_copUiCursor
    Çalışma yeri: İSTEMCİ (terminal haritasının "MouseMoving" olayı)

    İmlecin altındaki noktanın canlı bilgisi (ATAK'taki alt bilgi çubuğu gibi): grid, yükseklik, bana olan mesafe ve yön.
    En çok 10 Hz çalışır (zaman kısıtı); yalnızca yerel hesap, ağ yok. Ölçüm sürerken (A noktası seçili) imleç konumu çizim için saklanır.

    Parametreler: olay [harita, x, y, fare üstünde mi]
    Dönüş: yok
*/

params ["_map", "_mx", "_my"];

private _now = diag_tickTime;
if (_now < (missionNamespace getVariable ["TC2_cop_cursorNext", 0])) exitWith {};
missionNamespace setVariable ["TC2_cop_cursorNext", _now + 0.1];

private _world = _map ctrlMapScreenToWorld [_mx, _my];
_world set [2, 0];
missionNamespace setVariable ["TC2_cop_cursor", _world];

private _grid = mapGridPosition _world;
private _half = floor ((count _grid) / 2);
private _distance = (getPosASL ACE_player) distance2D _world;
private _bearing = round ((getPosASL ACE_player) getDir _world);

(ctrlParent _map displayCtrl 92049) ctrlSetText format [
    "  %1 %2   YÜK %3 m   %4   %5° / %6 mil",
    _grid select [0, _half], _grid select [_half, _half],
    round (getTerrainHeightASL _world),
    [format ["%1 m", round _distance], format ["%1 km", (round (_distance / 100)) / 10]] select (_distance >= 2000),
    _bearing, round (_bearing * 6400 / 360)
];
