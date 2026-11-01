/*
    Fonksiyon: TC2_fnc_casGrid
    Çalışma yeri: Her makine (saf fonksiyon)

    Konumu 10 haneli grid olarak yazar ("12345 67890"), ACE'in genel fonksiyonuyla (ace_common_fnc_getMapGridFromPos).
    Doktrin, konumun datumunun belirtilmesini ister: bu sistemde datum = ARMA oyun grid'idir.

    Parametreler:
        0: konum <ARRAY>

    Dönüş: <STRING>
*/

params [["_pos", [0, 0, 0], [[]]]];

private _grid = [_pos, true] call ace_common_fnc_getMapGridFromPos;
private _half = floor ((count _grid) / 2);

format ["%1 %2", _grid select [0, _half], _grid select [_half, (count _grid) - _half]]
