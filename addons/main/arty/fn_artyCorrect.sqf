/*
    Fonksiyon: TC2_fnc_artyCorrect
    Çalışma yeri: SUNUCU (saf fonksiyon)

    Gözlemcinin düzeltmesini nişan noktasına uygular (ATP 3-09.30, bölüm 5). Düzeltmeler gözlemci-hedef (OT) hattına göre verilir:
      - ADD (+) / DROP (-): OT hattı boyunca, gözlemciden UZAĞA / yakına,
      - LEFT (-) / RIGHT (+): OT hattına dik, gözlemcinin sol/sağına (gözlemci hedefe bakarken),
      - UP (+) / DOWN (-): dikey, metre.

    Parametreler:
        0: nişan noktası <ARRAY>  [x,y,z] ASL
        1: OT yönü, mil <NUMBER>  (gözlemciden hedefe, grid azimutu)
        2: sapma, metre <NUMBER>  (+ sağ, - sol)
        3: menzil, metre <NUMBER> (+ ADD, - DROP)
        4: dikey, metre <NUMBER>  (+ UP, - DOWN)

    Dönüş: yeni nişan noktası <ARRAY>
*/

params [["_pos", [0, 0, 0], [[]]], ["_dirMils", 0, [0]], ["_right", 0, [0]], ["_add", 0, [0]], ["_up", 0, [0]]];

private _azimuth = [_dirMils] call TC2_fnc_artyMilsToDeg;

// ileri = OT hattı; sağ = ileriye bakan gözlemcinin sağı
private _forward = [sin _azimuth, cos _azimuth];
private _rightVector = [cos _azimuth, -(sin _azimuth)];

[
    (_pos select 0) + (_forward select 0) * _add + (_rightVector select 0) * _right,
    (_pos select 1) + (_forward select 1) * _add + (_rightVector select 1) * _right,
    (_pos select 2) + _up
]
