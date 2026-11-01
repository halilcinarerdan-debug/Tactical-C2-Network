/*
    Fonksiyon: TC2_fnc_uiBuildFrame
    Çalışma yeri: İstemci (uiOpen çağırır, ekran alanı kurulmadan ÖNCE)

    Cihaz çerçevesini çizer; yalnızca görünüm (düz renkli dikdörtgenler, kare başına iş yok). Çerçeve ekran alanının DIŞINDA kalır.
      DESK  masa başı terminal: ince siyah çerçeveli dizüstü ekranı, alt çenede LED ve yazı, altta klavye gövdesi
      FIELD saha cihazı: ATAK tarzı sağlam kılıflı tablet/telefon: kum rengi kılıf, siyah ekran kenarı, üst/alt tutucu, kamera, sağda tuşlar
    IDC: 92050-92064

    Parametreler:
        0: pencere <DISPLAY>   1: mod <STRING> "DESK" | "FIELD"   2: sol   3: üst   4: genişlik   5: yükseklik   (ekran alanı)

    Dönüş: yok
*/

params ["_display", "_mode", "_left", "_top", "_w", "_h"];

private _idc = 92050;
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
    params ["_x", "_y", "_size", "_color"];
    private _control = _display ctrlCreate ["RscPicture", _idc];
    _idc = _idc + 1;
    _control ctrlSetText "\A3\ui_f\data\map\markers\military\dot_CA.paa";
    _control ctrlSetTextColor _color;
    _control ctrlSetPosition [_x, _y, _size, _size * (safeZoneH / safeZoneW) * (getResolution select 4)];
    _control ctrlCommit 0;
    _control
};

private _cx = _left + _w / 2;

if (_mode isEqualTo "DESK") then {
    private _bezel = 0.012;
    private _chin = 0.034;
    [_left - _bezel, _top - _bezel, _w + 2 * _bezel, _h + _bezel + _chin, [0.05, 0.05, 0.06, 1]] call _rect;
    [_left - 0.004, _top - 0.004, _w + 0.008, _h + 0.008, [0, 0.12, 0.03, 1]] call _rect;
    // alt çene: LED + yazı
    private _label = [_cx - 0.06, _top + _h + 0.004, 0.12, 0.026, [0, 0, 0, 0]] call _rect;
    _label ctrlSetText "TC2";
    _label ctrlSetTextColor [0.35, 0.35, 0.38, 1];
    _label ctrlSetFontHeight 0.02;
    [_left + 0.012, _top + _h + 0.012, 0.006, 0.01, [0.2, 0.9, 0.3, 1]] call _rect;
    // kamera noktası (üst çerçeve)
    [_cx - 0.003, _top - 0.0085, 0.006, 0.005, [0.15, 0.15, 0.18, 1]] call _rect;
    // klavye gövdesi + menteşe oyuğu
    [_left - 0.05, _top + _h + _chin - 0.002, _w + 0.1, 0.016, [0.1, 0.1, 0.11, 1]] call _rect;
    [_cx - 0.06, _top + _h + _chin - 0.002, 0.12, 0.006, [0.04, 0.04, 0.05, 1]] call _rect;
} else {
    private _caseL = 0.03;
    private _caseR = 0.05;
    private _caseV = 0.022;
    // kılıf (kum rengi) + ekran kenarı (siyah)
    [_left - _caseL, _top - _caseV, _w + _caseL + _caseR, _h + 2 * _caseV, [0.31, 0.28, 0.21, 1]] call _rect;
    [_left - 0.008, _top - 0.008, _w + 0.016, _h + 0.016, [0.02, 0.02, 0.02, 1]] call _rect;
    // üst ve alt tutucu
    [_cx - 0.08, _top - _caseV - 0.014, 0.16, 0.016, [0.07, 0.07, 0.07, 1]] call _rect;
    [_cx - 0.08, _top + _h + _caseV - 0.002, 0.16, 0.016, [0.07, 0.07, 0.07, 1]] call _rect;
    // yan tuşlar (sağda, kılıfın dışında)
    [_left + _w + _caseR, _top + _h * 0.25, 0.006, 0.08, [0.07, 0.07, 0.07, 1]] call _rect;
    [_left + _w + _caseR, _top + _h * 0.45, 0.006, 0.05, [0.07, 0.07, 0.07, 1]] call _rect;
    // kamera (solda) ve sağ kenar tuşları (geri / çoklu görev: yalnızca görünüm)
    [_left - _caseL + 0.008, _top + _h * 0.5 - 0.008, 0.016, [0.04, 0.04, 0.04, 1]] call _dot;
    [_left + _w + 0.016, _top + _h * 0.62, 0.022, [0.18, 0.18, 0.18, 1]] call _dot;
    [_left + _w + 0.016, _top + _h * 0.76, 0.022, [0.18, 0.18, 0.18, 1]] call _dot;
};
