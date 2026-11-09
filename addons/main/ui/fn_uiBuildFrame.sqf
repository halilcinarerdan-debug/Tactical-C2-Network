/*
    Fonksiyon: TC2_fnc_uiBuildFrame
    Çalışma yeri: İstemci (uiOpen çağırır, ekran alanı kurulmadan ÖNCE)

    Cihaz çerçevesini çizer; yalnızca görünüm (düz renkli şekiller, kare başına iş yok). Çerçeve ekran alanının DIŞINDA kalır.
    Yuvarlak köşe = orta dikdörtgen + üstte/altta çeyrek daire yayını izleyen ince şeritler (doku yok, kare piksel oranı korunur).
    Ekranın kendi köşeleri uiBuildFrameCorners ile (içerik kurulduktan SONRA) kaplanır.
      DESK  masa başı bilgisayar: ince çerçeveli monitör (üst parlama, LED, güç tuşu), boyun + taban, önünde klavye ve fare
      FIELD saha cihazı: sağlam 8" taktik tablet (Samsung Galaxy Tab Active5 Tactical Edition'ı andırır): koyu yeşil kılıf, köşe koruyucular, çıkıntılı iç kenar,
            üst tuşlar, ön kamera, altta pogo noktaları. Marka logosu yoktur.
    IDC: 93000-93199

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
// Daire dokusu KULLANILMAZ (dot_CA kenarlarında boşluk var, köşeler içe çökük görünüyordu). Köşe = ince yatay şeritler (çeyrek daire yayı).
// Şerit sayısı yarıçapa göre uyarlanır. Şerit k'nın yatay girintisi: r * (1 - sqrt(1 - ((n - k - 0.5) / n)^2)); şeritler 1 piksel kadar çakıştırılır, dikiş kalmaz.
private _strips = {
    params ["_x", "_y", "_rw", "_rh", "_r", "_color", "_flip"];
    private _rv = _r * _ratio;
    // şerit sayısı yarıçapa göre: her ~4 piksel için bir şerit (3 ile 12 arası); büyük köşe pürüzsüz, küçük köşe az kontrol
    private _steps = (3 max (round (_r * ((getResolution select 2) / safeZoneW) / 4))) min 12;
    private _stripH = _rv / _steps;
    for "_k" from 0 to (_steps - 1) do {
        private _t = (_steps - _k - 0.5) / _steps;
        private _inset = _r * (1 - sqrt (1 - _t * _t));
        private _py = if (_flip) then {_y + _rh - (_k + 1) * _stripH} else {_y + _k * _stripH};
        [_x + _inset, _py, _rw - 2 * _inset, _stripH + 0.0012, _color] call _rect;
    };
};
// yuvarlak köşeli dikdörtgen; r = köşe yarıçapı (x biriminde)
private _round = {
    params ["_x", "_y", "_rw", "_rh", "_r", "_color"];
    private _rv = _r * _ratio;
    [_x, _y + _rv - 0.0006, _rw, _rh - 2 * _rv + 0.0012, _color] call _rect;
    [_x, _y, _rw, _rh, _r, _color, false] call _strips;
    [_x, _y, _rw, _rh, _r, _color, true] call _strips;
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

missionNamespace setVariable ["TC2_ui_frame", [_mode, _left, _top, _w, _h]];

private _cx = _left + _w / 2;

if (_mode isEqualTo "DESK") then {
    // MASA BAŞI BİLGİSAYAR: ince çerçeveli monitör + boyun + taban, önünde klavye ve fare.
    private _side = 0.018;
    private _chin = 0.045;
    private _bodyTop = _top - _side;
    private _bodyH = _h + _side + _chin;
    private _bodyBottom = _top + _h + _chin;

    // ayak (monitörün arkasında kalacak şekilde önce): boyun + taban
    [_cx - 0.032, _bodyBottom - 0.004, 0.064, 0.034, [0.15, 0.15, 0.16, 1]] call _rect;
    [_cx - 0.012, _bodyBottom + 0.004, 0.024, 0.026, [0.1, 0.1, 0.11, 1]] call _rect;
    [_cx - 0.13, _bodyBottom + 0.028, 0.26, 0.016, 0.008, [0.11, 0.11, 0.12, 1]] call _round;

    // klavye gövdesi + tuş sıraları (3 sıra x 14 tuş + boşluk çubuğu), sağında fare
    private _kbTop = _bodyBottom + 0.052;
    private _kbW = 0.42;
    private _kbLeft = _cx - _kbW / 2;
    [_kbLeft, _kbTop, _kbW, 0.054, 0.008, [0.09, 0.09, 0.1, 1]] call _round;
    private _keyW = (_kbW - 0.016) / 14;
    for "_row" from 0 to 2 do {
        for "_col" from 0 to 13 do {
            [_kbLeft + 0.008 + _col * _keyW + 0.0012, _kbTop + 0.006 + _row * 0.0125, _keyW - 0.0024, 0.0105, [0.2, 0.2, 0.22, 1]] call _rect;
        };
    };
    [_kbLeft + 0.06, _kbTop + 0.0435, _kbW - 0.12, 0.0085, [0.2, 0.2, 0.22, 1]] call _rect;
    [_kbLeft + _kbW + 0.022, _kbTop + 0.006, 0.026, 0.044, 0.011, [0.1, 0.1, 0.11, 1]] call _round;
    [_kbLeft + _kbW + 0.0345, _kbTop + 0.006, 0.0012, 0.017, [0.03, 0.03, 0.03, 1]] call _rect;

    // monitör gövdesi: koyu antrasit çerçeve, üst kenarda ince parlama, ekran girintisi
    [_left - _side, _bodyTop, _w + 2 * _side, _bodyH, 0.016, [0.075, 0.075, 0.085, 1]] call _round;
    [_left - _side + 0.016, _bodyTop + 0.001, _w + 2 * _side - 0.032, 0.0014, [0.22, 0.22, 0.25, 1]] call _rect;
    [_left - 0.006, _top - 0.006, _w + 0.012, _h + 0.012, [0.01, 0.03, 0.015, 1]] call _rect;

    // çene: yazı, güç LED'i ve güç tuşu
    private _label = [_cx - 0.06, _top + _h + 0.012, 0.12, 0.026, [0, 0, 0, 0]] call _rect;
    _label ctrlSetText "TC2";
    _label ctrlSetTextColor [0.4, 0.4, 0.44, 1];
    _label ctrlSetFontHeight 0.022;
    [_left + _w - 0.052, _top + _h + 0.017, 0.03, 0.014, 0.005, [0.16, 0.16, 0.18, 1]] call _round;
    [_left + _w - 0.094, _top + _h + 0.0205, 0.009, [0.2, 0.9, 0.3, 1]] call _dot;
    // web kamerası (üst çerçeve)
    [_cx - 0.005, _top - 0.0125, 0.01, [0.2, 0.2, 0.24, 1]] call _dot;
} else {
    // SAHA CİHAZI: sağlam 8" taktik tablet (Samsung Galaxy Tab Active5 Tactical Edition'ı andıran koyu yeşil kılıf, kalın çerçeve, köşe koruyucular,
    // üst kenarda tuşlar, altta pogo temas noktaları, solda ön kamera). Yatay kullanım.
    private _side = 0.058;
    private _vert = 0.042;
    private _case = [0.16, 0.19, 0.13, 1];
    private _dark = [0.09, 0.11, 0.07, 1];
    private _bumperW = 0.082;
    private _bumperH = _bumperW * _ratio;

    // üst kenar tuşları (kılıfın arkasından taşar): Active tuşu (geniş), güç, ses
    [_left + _w * 0.58, _top - _vert - 0.0075, 0.05, 0.0105, [0.06, 0.07, 0.05, 1]] call _rect;
    [_left + _w * 0.58 + 0.062, _top - _vert - 0.006, 0.026, 0.009, [0.06, 0.07, 0.05, 1]] call _rect;
    [_left + _w * 0.58 + 0.098, _top - _vert - 0.006, 0.04, 0.009, [0.06, 0.07, 0.05, 1]] call _rect;

    // kılıf (koyu yeşil, mat kauçuk) + köşe koruyucular + çıkıntılı iç kenar + siyah ekran çerçevesi
    [_left - _side, _top - _vert, _w + 2 * _side, _h + 2 * _vert, 0.036, _case] call _round;
    [_left - _side, _top - _vert, _bumperW, _bumperH, 0.036, _dark] call _round;
    [_left + _w + _side - _bumperW, _top - _vert, _bumperW, _bumperH, 0.036, _dark] call _round;
    [_left - _side, _top + _h + _vert - _bumperH, _bumperW, _bumperH, 0.036, _dark] call _round;
    [_left + _w + _side - _bumperW, _top + _h + _vert - _bumperH, _bumperW, _bumperH, 0.036, _dark] call _round;
    [_left - 0.03, _top - 0.024, _w + 0.06, _h + 0.048, 0.02, [0.12, 0.145, 0.095, 1]] call _round;
    [_left - 0.018, _top - 0.0155, _w + 0.036, _h + 0.031, 0.012, [0.02, 0.02, 0.02, 1]] call _round;
    // kılıf üst kenarında ince parlama
    [_left - _side + 0.036, _top - _vert + 0.0015, _w + 2 * _side - 0.072, 0.0015, [0.3, 0.35, 0.25, 1]] call _rect;

    // sol çerçeve: ön kamera + sensör; sağ çerçeve: iki sensör
    [_left - 0.0335, _top + _h * 0.5 - 0.007, 0.014, [0.04, 0.04, 0.05, 1]] call _dot;
    [_left - 0.0335 + 0.003, _top + _h * 0.5 - 0.007 + 0.003 * _ratio, 0.008, [0.12, 0.14, 0.2, 1]] call _dot;
    [_left - 0.0305, _top + _h * 0.5 - 0.036, 0.006, [0.1, 0.1, 0.1, 1]] call _dot;
    [_left + _w + 0.0225, _top + _h * 0.5 - 0.012, 0.007, [0.08, 0.08, 0.08, 1]] call _dot;
    [_left + _w + 0.0225, _top + _h * 0.5 + 0.012, 0.007, [0.08, 0.08, 0.08, 1]] call _dot;

    // alt kenar: pogo temas noktaları (altın) ve yazı
    for "_k" from 0 to 3 do {
        [_left + _w * 0.5 - 0.027 + _k * 0.018, _top + _h + 0.0235, 0.0065, [0.8, 0.65, 0.25, 1]] call _dot;
    };
    private _tag = [_left + 0.02, _top + _h + 0.0185, 0.12, 0.022, [0, 0, 0, 0]] call _rect;
    _tag ctrlSetText "TC2 TACTICAL";
    _tag ctrlSetTextColor [0.42, 0.5, 0.36, 1];
    _tag ctrlSetFontHeight 0.016;
};
