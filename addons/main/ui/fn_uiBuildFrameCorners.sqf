/*
    Fonksiyon: TC2_fnc_uiBuildFrameCorners
    Çalışma yeri: İstemci (uiOpen çağırır, TÜM içerik kurulduktan sonra: kontroller sırayla üst üste çizilir)

    Ekranın dört köşesini çerçeve renginde ince şeritlerle kaplar; böylece ekran içeriği de yuvarlak köşeli görünür
    (uiBuildFrame yalnızca çerçevenin dışını yuvarlar). Yarıçap küçüktür (0.014); köşedeki birkaç piksel içerik kapanır.
    Köşe renkleri uiBuildFrame'deki ekran kenarıyla aynıdır (masa başı: koyu yeşilimsi girinti, saha: siyah kenar).
    IDC: 93200-93299

    Parametreler: yok (geometri TC2_ui_frame değişkeninden: [mod, sol, üst, genişlik, yükseklik])
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

(missionNamespace getVariable ["TC2_ui_frame", []]) params [["_mode", ""], ["_left", 0], ["_top", 0], ["_w", 0], ["_h", 0]];
if (_mode isEqualTo "") exitWith {};

private _color = if (_mode isEqualTo "DESK") then {[0.01, 0.03, 0.015, 1]} else {[0.03, 0.03, 0.03, 1]};
private _ratio = (safeZoneH / safeZoneW) * (getResolution select 4);
private _r = 0.014;
private _rv = _r * _ratio;
private _steps = 5;
private _stripH = _rv / _steps;
private _idc = 93200;

for "_k" from 0 to (_steps - 1) do {
    // üst: şerit k'nın dışta kalan (maskelenecek) yatay payı = girinti
    private _t = (_steps - _k - 0.5) / _steps;
    private _inset = _r * (1 - sqrt (1 - _t * _t));
    {
        _x params ["_px", "_py", "_pw"];
        private _control = _display ctrlCreate ["RscText", _idc];
        _idc = _idc + 1;
        _control ctrlSetPosition [_px, _py, _pw, _stripH + 0.0012];
        _control ctrlSetBackgroundColor _color;
        _control ctrlCommit 0;
    } forEach [
        [_left, _top + _k * _stripH, _inset],
        [_left + _w - _inset, _top + _k * _stripH, _inset],
        [_left, _top + _h - (_k + 1) * _stripH, _inset],
        [_left + _w - _inset, _top + _h - (_k + 1) * _stripH, _inset]
    ];
};
