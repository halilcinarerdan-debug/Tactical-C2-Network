/*
    Fonksiyon: TC2_fnc_rptLaceStatus
    Çalışma yeri: Her makine (saf fonksiyon)

    Bir birliğin LACE özet durumu: sistemin doğruladığı sayılardan hesaplanan durum ile liderin beyan ettiği durumların EN KÖTÜSÜ.
      etkin kuvvet oranı = (mevcut - yaralı/etkisiz) / ilk büyüklük   ->  >= 0.8 GREEN, >= 0.6 AMBER, >= 0.4 RED, altı BLACK
      araç hasarı >= 70 yüzde -> en az RED, >= 40 yüzde -> en az AMBER
    Eşikler SOP'a göre değişir; burada tipik değerler alınmıştır (bkz. docs/DOKTRIN_NOTLARI_RAPORLAR.md, doğrulanmamış genel bilgi).

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
_worst = _worst max (if (_ratio >= 0.8) then {0} else {if (_ratio >= 0.6) then {1} else {if (_ratio >= 0.4) then {2} else {3}}});
if (_vehicle >= 70) then {_worst = _worst max 2} else {if (_vehicle >= 40) then {_worst = _worst max 1}};

if !(_report isEqualTo []) then {
    private _data = _report select 1;
    {
        private _index = _rank find (_data select (_x * 2));
        if (_index > _worst) then {_worst = _index};
    } forEach [0, 1, 2, 3];
};

_rank select _worst
