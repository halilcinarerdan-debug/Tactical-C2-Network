/*
    Fonksiyon: TC2_fnc_medLines
    Çalışma yeri: Her makine (saf fonksiyon)

    MEDEVAC talebini okunur 9 satıra çevirir.

    Parametreler:
        0: veri <ARRAY of STRING>  (medValidate biçimi)
        1: ek bilgi <ARRAY>  [alım yeri grid metni <STRING>, çağrı adı <STRING>, ağ metni <STRING>]

    Dönüş: [[etiket, değer]] <ARRAY>
*/

params [["_data", [], [[]]], ["_extra", [], [[]]]];

_extra params [["_grid", ""], ["_callsign", ""], ["_net", ""]];

private _pick = {
    params ["_key", "_pairs"];
    private _result = _key;
    {
        if ((_x select 0) isEqualTo _key) exitWith {_result = format ["%1  %2", _key, _x select 1]};
    } forEach _pairs;
    _result
};

private _precedence = [];
{
    private _count = _data select (2 + _forEachIndex);
    if !(_count isEqualTo "0") then {
        _precedence pushBack format ["%1 x %2 %3", _count, _x select 0, _x select 1];
    };
} forEach [["A", "acil"], ["B", "acil-cerrahi"], ["C", "öncelikli"], ["D", "rutin"], ["E", "kolaylık"]];

private _types = [];
if !((_data select 8) isEqualTo "0") then {_types pushBack format ["%1 sedyeli (L)", _data select 8]};
if !((_data select 9) isEqualTo "0") then {_types pushBack format ["%1 yürüyebilen (A)", _data select 9]};

[
    ["1  ALIM YERİ", _grid],
    ["2  FREKANS / ÇAĞRI ADI", format ["%1   %2%3", _callsign, _net, ["", "   " + (_data select 1)] select !((_data select 1) isEqualTo "")]],
    ["3  HASTA / ÖNCELİK", _precedence joinString ",  "],
    ["4  ÖZEL EKİPMAN", [_data select 7, [["A", "yok"], ["B", "vinç"], ["C", "kurtarma ekipmanı"], ["D", "ventilatör"]]] call _pick],
    ["5  HASTA TİPİ", _types joinString ",  "],
    ["6  GÜVENLİK", [_data select 10, [["N", "düşman yok"], ["P", "olası düşman"], ["E", "DÜŞMAN VAR - dikkatle yaklaş"], ["X", "silahlı eskort şart"]]] call _pick],
    ["7  İŞARETLEME", [_data select 11, [["A", "panel"], ["B", "piroteknik"], ["C", "duman"], ["D", "yok"], ["E", "diğer"]]] call _pick],
    ["8  UYRUK / DURUM", [_data select 12, [["A", "dost asker"], ["B", "dost sivil"], ["C", "dost dışı asker"], ["D", "dost dışı sivil"], ["E", "düşman esir"]]] call _pick],
    ["9  CBRN", if ((_data select 13) isEqualTo "") then {"yok"} else {[_data select 13, [["N", "nükleer"], ["B", "biyolojik"], ["C", "kimyasal"]]] call _pick}]
]
