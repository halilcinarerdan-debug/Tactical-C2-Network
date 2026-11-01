/*
    Fonksiyon: TC2_fnc_artyMilsToDeg
    Çalışma yeri: Her makine (saf fonksiyon)

    Topçu yönleri milliyem (NATO: 6400 = tam daire). Arma azimutları derecedir. 1 mil = 0.05625 derece (1° = 17.78 mil).

    Parametreler:
        0: açı <NUMBER>
        1: yön <STRING>  "TODEG" (mil -> derece, varsayılan) | "TOMIL" (derece -> mil)

    Dönüş: <NUMBER>
*/

params [["_value", 0, [0]], ["_mode", "TODEG", [""]]];

if (_mode isEqualTo "TOMIL") then {_value * 6400 / 360} else {_value * 360 / 6400}
