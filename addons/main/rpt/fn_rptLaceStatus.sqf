/*
    Fonksiyon: TC2_fnc_rptLaceStatus
    Çalışma yeri: Her makine (saf fonksiyon)

    Bir birliğin LACE özet durumu: sistemin doğruladığı sayılardan hesaplanan durum ile liderin beyan ettiği durumların EN KÖTÜSÜ.
    Renk eşikleri ATP 3-21.8 2-80 (FM 1-02.2): tam operasyonel GREEN (yüzde 85 ve üstü), büyük ölçüde AMBER (70-84),
    sınırlı RED (50-69), operasyonel değil BLACK (50 altı), UNKNOWN (bilinmiyor; en kötü hesabına katılmaz).
      etkin kuvvet oranı = (mevcut - yaralı/etkisiz) / ilk büyüklük
      araç durumu = 100 - hasar yüzde; araç tek başına en çok RED yapar

    Parametreler:
        0: lace <ARRAY>  rptLaceInfo çıktısı [[mevcut, ilk, yaralı, araç %], son rapor [yaş, [[durum, not] x4 düz 8 metin]]]

    Dönüş: "GREEN" | "AMBER" | "RED" | "BLACK" | "" (LACE yok) <STRING>
*/

params [["_lace", [], [[]]]];

if (_lace isEqualTo []) exitWith {""};

_lace params ["_auto", "_report"];
_auto params ["_alive", "_initial", "_wounded", "_vehicle"];

private _rank = ["GREEN", "AMBER", "RED", "BLACK"];
private _worst = 0;

private _ratio = if (_initial > 0) then {(_alive - _wounded) / _initial} else {0};
_worst = _worst max (if (_ratio >= 0.85) then {0} else {if (_ratio >= 0.7) then {1} else {if (_ratio >= 0.5) then {2} else {3}}});
private _vehicleReady = (100 - _vehicle) / 100;
_worst = _worst max (if (_vehicleReady >= 0.85) then {0} else {if (_vehicleReady >= 0.7) then {1} else {2}});

if !(_report isEqualTo []) then {
    private _data = _report select 1;
    {
        private _index = _rank find (_data select (_x * 2));
        if (_index > _worst) then {_worst = _index};
    } forEach [0, 1, 2, 3];
};

_rank select _worst
