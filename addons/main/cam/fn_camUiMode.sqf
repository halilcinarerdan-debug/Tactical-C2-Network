/*
    Fonksiyon: TC2_fnc_camUiMode
    Çalışma yeri: İstemci (mod düğmeleri)

    Görüntü modu: 0 NORMAL, 1 NVG (gece görüş), 2 TERMAL (beyaz sıcak). Yalnızca izleyenin kendi ekranındaki görüntüyü etkiler;
    İHA'ya ya da kaynağa HİÇBİR komut gitmez.

    Parametreler:
        0: mod <NUMBER>

    Dönüş: yok
*/

params [["_mode", 0, [0]]];

missionNamespace setVariable ["TC2_cam_mode", _mode];
"tc2_cam_rtt" setPiPEffect [_mode];

private _display = findDisplay 92000;
if (isNull _display) exitWith {};
{
    (_display displayCtrl (92903 + _x)) ctrlSetBackgroundColor ([[0.02, 0.1, 0.03, 1], [0.1, 0.45, 0.15, 1]] select (_x == _mode));
} forEach [0, 1, 2];
