/*
    Fonksiyon: TC2_fnc_casCompare
    Çalışma yeri: SUNUCU (saf fonksiyon)

    Pilotun GERİ OKUMASINI JTAC'ın gönderdiğiyle karşılaştırır. Doktrin (JP 3-09.3): satır 4 (yükseklik), satır 6 (konum)
    ve TÜM kısıtlar zorunlu geri okuma öğeleridir. Yalnızca verilmiş kısıtlar istenir.

    Cevaplar: [yükseklik <NUMBER>, konum <STRING>, FAH <NUMBER>, danger close <STRING>, ACA <STRING>, TOT <STRING>]
    (sayısal alan girilmediyse -99999). Karşılaştırma: sayılar tam eşit, metinler büyük/küçük harf ve fazla boşluğa duyarsız,
    konumda yalnızca rakamlar.

    Parametreler:
        0: form verisi <ARRAY>
        1: cevaplar <ARRAY>

    Dönüş: [[anahtar, etiket, doğru mu <BOOL>, doğru değer <STRING>]] <ARRAY>
*/

params [["_data", [], [[]]], ["_answers", [], [[]]]];

if (count _data != 19 || {count _answers != 6}) exitWith {[]};

private _text = {toUpper ((_this splitString " ") joinString " ")};
private _digits = {(_this splitString " -") joinString ""};

_answers params ["_answerElevation", "_answerGrid", "_answerFah", "_answerDc", "_answerAca", "_answerTot"];

private _elevation = _data select 6;
private _grid = [_data select 8] call TC2_fnc_casGrid;
private _fah = _data select 15;
private _aca = _data select 16;
private _dc = _data select 17;
private _tot = _data select 18;

private _results = [];

_results pushBack ["ELEV", "SATIR 4 YÜKSEKLİK", _answerElevation == _elevation, format ["%1 ft", _elevation]];
_results pushBack ["GRID", "SATIR 6 KONUM", ((_answerGrid call _digits) isEqualTo (_grid call _digits)), _grid];

if (_fah >= 0) then {_results pushBack ["FAH", "KISIT SON SALDIRI YÖNÜ", _answerFah == _fah, format ["%1", _fah]]};
if !(_aca isEqualTo "") then {_results pushBack ["ACA", "KISIT ACA", ((_answerAca call _text) isEqualTo (_aca call _text)), _aca]};
if !(_dc isEqualTo "") then {_results pushBack ["DC", "KISIT DANGER CLOSE", ((_answerDc call _text) isEqualTo (_dc call _text)), toUpper _dc]};
if !(_tot isEqualTo "") then {_results pushBack ["TOT", "KISIT TOT/TTT", ((_answerTot call _text) isEqualTo (_tot call _text)), _tot]};

_results
