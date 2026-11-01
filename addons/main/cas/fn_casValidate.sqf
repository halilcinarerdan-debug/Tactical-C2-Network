/*
    Fonksiyon: TC2_fnc_casValidate
    Çalışma yeri: Her makine (saf fonksiyon). Sunucu bunu KARAR için, istemci kolaylık (anında geri bildirim) için çağırır.

    9-Line formunu doktrine (JP 3-09.3, Figure V-14) göre denetler. Form verisi 19 elemanlı sabit dizidir:

        0 kontrol türü (1|2|3)           10 işaret kodu (lazer: 4 hane, aksi "")
        1 BOT | BOC                      11 dost mesafesi, metre (-1 = yok)
        2 IP/BP                          12 dost yönü (N NE E SE S SW W NW | "")
        3 heading (0-359, derece)        13 egress
        4 offset ("" | "L" | "R")        14 remarks
        5 distance                       15 son saldırı yönü / FAH (-1 = yok)
        6 hedef yüksekliği (ft MSL)      16 ACA
        7 hedef tanımı                   17 danger close, komutan baş harfleri ("" = yok)
        8 hedef konumu (ASL dizisi)      18 TOT/TTT
        9 işaret türü (NONE|SMOKE|LASER|IR)

    Doktrin kuralları: Type 1 her zaman BOT; heading 0-359; mesafe sabit kanatta nm (0.1 hassasiyet),
    döner kanatta metre (100 m'ye yuvarlanmış); lazer işaretinde 4 haneli kod; dostlar metre + kardinal yön;
    danger close komutanın baş harfleriyle birlikte verilir.

    Parametreler:
        0: form verisi <ARRAY>
        1: platform <STRING>  "FW" (sabit kanat) | "RW" (döner kanat)

    Dönüş: [geçerli mi <BOOL>, hatalar <ARRAY of STRING>]
*/

params [["_data", [], [[]]], ["_platform", "FW", [""]]];

private _shape = [0, "", "", 0, "", 0, 0, "", [], "", "", 0, "", "", "", 0, "", "", ""];

if (count _data != count _shape) exitWith {[false, ["Geçersiz form."]]};

private _typesOk = true;
{
    if !((_data select _forEachIndex) isEqualType _x) exitWith {_typesOk = false};
} forEach _shape;
if (!_typesOk) exitWith {[false, ["Geçersiz form verisi."]]};

_data params [
    "_type", "_bot", "_ip", "_heading", "_offset", "_distance", "_elevation", "_description", "_pos",
    "_markType", "_markCode", "_friendlyDist", "_friendlyDir", "_egress", "_remarks", "_fah", "_aca", "_dc", "_tot"
];

private _errors = [];
private _cardinals = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];

if !(_type in [1, 2, 3]) then {_errors pushBack "Kontrol türü 1, 2 veya 3 olmalı."};
if !(_bot in ["BOT", "BOC"]) then {_errors pushBack "BOT veya BOC seçin."};
if (_type == 1 && {_bot isEqualTo "BOC"}) then {_errors pushBack "Type 1 her zaman BOT'tur (BOC seçilemez)."};

if (_ip isEqualTo "" || {count _ip > 24}) then {_errors pushBack "Satır 1: IP/BP gerekli (en çok 24 karakter)."};

if (_heading < 0 || {_heading > 359} || {_heading != floor _heading}) then {_errors pushBack "Satır 2: heading 0-359 tam sayı olmalı."};
if !(_offset in ["", "L", "R"]) then {_errors pushBack "Satır 2: offset geçersiz."};

if (_distance <= 0) then {
    _errors pushBack "Satır 3: mesafe 0'dan büyük olmalı.";
} else {
    if (_platform isEqualTo "RW") then {
        if ((_distance mod 100) != 0) then {_errors pushBack "Satır 3: döner kanatta mesafe metre cinsinden ve 100 m'nin katı olmalı."};
    } else {
        if (_distance > 99.9 || {abs ((_distance * 10) - (round (_distance * 10))) > 0.001}) then {_errors pushBack "Satır 3: sabit kanatta mesafe nm cinsinden, 0.1 hassasiyetinde (en çok 99.9) olmalı."};
    };
};

if (_elevation < -1500 || {_elevation > 40000} || {_elevation != floor _elevation}) then {_errors pushBack "Satır 4: yükseklik feet MSL, tam sayı olmalı."};

if (_description isEqualTo "" || {count _description > 60}) then {_errors pushBack "Satır 5: hedef tanımı gerekli (en çok 60 karakter)."};

if !(count _pos == 3 && {(_pos select 0) isEqualType 0} && {(_pos select 1) isEqualType 0} && {(_pos select 2) isEqualType 0}) then {_errors pushBack "Satır 6: hedef konumu seçilmedi."};

if !(_markType in ["NONE", "SMOKE", "LASER", "IR"]) then {
    _errors pushBack "Satır 7: işaret türü geçersiz.";
} else {
    if (_markType isEqualTo "LASER") then {
        if !(count _markCode == 4 && {count ((toArray _markCode) select {_x < 48 || {_x > 57}}) == 0}) then {_errors pushBack "Satır 7: lazer işaretinde 4 haneli kod gerekli."};
    } else {
        if !(_markCode isEqualTo "") then {_errors pushBack "Satır 7: kod yalnızca lazer işaretinde verilir."};
    };
};

if (_friendlyDist != -1) then {
    if (_friendlyDist < 0 || {!(_friendlyDir in _cardinals)}) then {_errors pushBack "Satır 8: dost mesafesi (metre) ve yönü (N NE E SE S SW W NW) birlikte verilmeli."};
} else {
    if !(_friendlyDir isEqualTo "") then {_errors pushBack "Satır 8: mesafe yokken yön verilemez."};
};

if (_egress isEqualTo "" || {count _egress > 30}) then {_errors pushBack "Satır 9: egress gerekli (en çok 30 karakter)."};

if (count _remarks > 100) then {_errors pushBack "Remarks en çok 100 karakter."};

if (_fah != -1 && {_fah < 0 || {_fah > 359} || {_fah != floor _fah}}) then {_errors pushBack "Kısıt: son saldırı yönü 0-359 olmalı."};
if (count _aca > 30) then {_errors pushBack "Kısıt: ACA en çok 30 karakter."};
if !(_dc isEqualTo "") then {
    if !(count _dc in [2, 3] && {count ((toArray (toUpper _dc)) select {_x < 65 || {_x > 90}}) == 0}) then {_errors pushBack "Kısıt: danger close için komutanın baş harfleri (2-3 harf) gerekli."};
};
if (count _tot > 20) then {_errors pushBack "Kısıt: TOT/TTT en çok 20 karakter."};

[_errors isEqualTo [], _errors]
