/*
    Fonksiyon: TC2_fnc_uiBuildFrame
    Çalışma yeri: İstemci (uiOpen çağırır, ekran alanı kurulmadan ÖNCE)

    Cihaz çerçevesini çizer; yalnızca görünüm (düz renkli şekiller, kare başına iş yok). Çerçeve ekran alanının DIŞINDA kalır.
    Yuvarlak köşe = iki çakışan dikdörtgen + dört daire (oyunun dot_CA simgesi); daire boyu piksel olarak kare kalacak şekilde oranlanır.
      DESK  masa başı terminal: masaüstü monitörü; kalın siyah çerçeve, yuvarlak köşeler, alt çenede LED / güç tuşu / "TC2", boyun ve ayak
      FIELD saha cihazı: ATAK tarzı sağlam kılıflı tablet; kalın kum rengi kılıf, yuvarlak köşeler, siyah ekran kenarı, tutucular, yan tuşlar, kamera
    IDC: 93000 ve sonrası (en çok ~50)

    Parametreler:
        0: pencere <DISPLAY>   1: mod <STRING> "DESK" | "FIELD"   2: sol   3: üst   4: genişlik   5: yükseklik   (ekran alanı)

    Dönüş: yok
*/

params ["_display", "_mode", "_left", "_top", "_w", "_h"];

private _idc = 93000;
private _ratio = (safeZoneH / safeZoneW) * (getResolution select 4);   // x birimini y birimine çevirir (kare piksel)

private _rect = {
    params ["_x", "_y", "_rw", "_rh", "_color"];
    private _control = _display ctrlCreate ["RscText", _idc];
    _idc = _idc + 1;
    _control ctrlSetPosition [_x, _y, _rw, _rh];
    _control ctrlSetBackgroundColor _color;
    _control ctrlCommit 0;
    _control
};
private _dot = {
    params ["_x", "_y", "_sizeX", "_color"];
    private _control = _display ctrlCreate ["RscPicture", _idc];
    _idc = _idc + 1;
    _control ctrlSetText "\A3\ui_f\data\map\markers\military\dot_CA.paa";
    _control ctrlSetTextColor _color;
    _control ctrlSetPosition [_x, _y, _sizeX, _sizeX * _ratio];
    _control ctrlCommit 0;
    _control
};
// yuvarlak köşeli dikdörtgen; r = köşe yarıçapı (x biriminde)
private _round = {
    params ["_x", "_y", "_rw", "_rh", "_r", "_color"];
    private _rv = _r * _ratio;
    [_x + _r, _y, _rw - 2 * _r, _rh, _color] call _rect;
    [_x, _y + _rv, _rw, _rh - 2 * _rv, _color] call _rect;
    [_x, _y, 2 * _r, _color] call _dot;
    [_x + _rw - 2 * _r, _y, 2 * _r, _color] call _dot;
    [_x, _y + _rh - 2 * _rv, 2 * _r, _color] call _dot;
    [_x + _rw - 2 * _r, _y + _rh - 2 * _rv, 2 * _r, _color] call _dot;
};

private _cx = _left + _w / 2;

if (_mode isEqualTo "DESK") then {
    private _side = 0.018;
    private _chin = 0.052;
    private _bodyTop = _top - _side;
    private _bodyH = _h + _side + _chin;

    // ayak: boyun + taban (monitörün arkasında kalacak şekilde önce çizilir)
    [_cx - 0.04, _top + _h + _chin - 0.004, 0.08, 0.05, [0.13, 0.13, 0.14, 1]] call _rect;
    [_cx - 0.14, _top + _h + _chin + 0.036, 0.28, 0.02, 0.01, [0.1, 0.1, 0.11, 1]] call _round;

    // gövde (kalın çerçeve) + ekran girintisi
    [_left - _side, _bodyTop, _w + 2 * _side, _bodyH, 0.016, [0.07, 0.07, 0.08, 1]] call _round;
    [_left - 0.006, _top - 0.006, _w + 0.012, _h + 0.012, [0.01, 0.03, 0.015, 1]] call _rect;

    // çene: LED, güç tuşu, yazı
    private _label = [_cx - 0.06, _top + _h + 0.014, 0.12, 0.028, [0, 0, 0, 0]] call _rect;
    _label ctrlSetText "TC2";
    _label ctrlSetTextColor [0.35, 0.35, 0.38, 1];
    _label ctrlSetFontHeight 0.022;
    [_left + _w - 0.05, _top + _h + 0.02, 0.03, 0.016, 0.006, [0.16, 0.16, 0.18, 1]] call _round;
    [_left + _w - 0.092, _top + _h + 0.026, 0.01, [0.2, 0.9, 0.3, 1]] call _dot;
    // kamera noktası (üst çerçeve)
    [_cx - 0.005, _top - 0.0125, 0.01, [0.2, 0.2, 0.24, 1]] call _dot;
} else {
    private _side = 0.052;
    private _vert = 0.046;
    private _rim = 0.022;

    // üst ve alt tutucu (kılıfın arkasından taşar)
    [_cx - 0.1, _top - _vert - 0.012, 0.2, 0.026, 0.01, [0.07, 0.07, 0.07, 1]] call _round;
    [_cx - 0.1, _top + _h + _vert - 0.014, 0.2, 0.026, 0.01, [0.07, 0.07, 0.07, 1]] call _round;

    // kılıf (kum rengi) ve siyah ekran kenarı
    [_left - _side, _top - _vert, _w + 2 * _side, _h + 2 * _vert, 0.032, [0.31, 0.28, 0.21, 1]] call _round;
    [_left - _rim, _top - _rim, _w + 2 * _rim, _h + 2 * _rim, 0.014, [0.03, 0.03, 0.03, 1]] call _round;

    // yan tuşlar (sağ kenar), kamera (sol), geri / çoklu görev (sağ; yalnızca görünüm)
    [_left + _w + _side - 0.002, _top + _h * 0.24, 0.007, 0.09, 0.003, [0.07, 0.07, 0.07, 1]] call _round;
    [_left + _w + _side - 0.002, _top + _h * 0.46, 0.007, 0.055, 0.003, [0.07, 0.07, 0.07, 1]] call _round;
    [_left - _side + 0.018, _top + _h * 0.5, 0.016, [0.03, 0.03, 0.03, 1]] call _dot;
    [_left + _w + _rim + 0.004, _top + _h * 0.62, 0.02, [0.2, 0.2, 0.2, 1]] call _dot;
    [_left + _w + _rim + 0.004, _top + _h * 0.76, 0.02, [0.2, 0.2, 0.2, 1]] call _dot;
};
