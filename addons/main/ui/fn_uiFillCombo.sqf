/*
    Fonksiyon: TC2_fnc_uiFillCombo
    Çalışma yeri: İstemci

    Açılır listeyi doldurur; önceki seçimi (veri alanına göre) korur. İlk satır her zaman yer tutucudur.

    Parametreler:
        0: liste <CONTROL>
        1: öğeler <ARRAY>  [[metin, veri]]
        2: yer tutucu <ARRAY>  [metin, veri]

    Dönüş: yok
*/

params ["_control", "_items", "_placeholder"];

if (isNull _control) exitWith {};

private _previous = _control lbData (lbCurSel _control);
lbClear _control;

private _first = _control lbAdd (_placeholder select 0);
_control lbSetData [_first, _placeholder select 1];

private _restore = 0;
{
    private _index = _control lbAdd (_x select 0);
    _control lbSetData [_index, _x select 1];
    if ((_x select 1) isEqualTo _previous) then {_restore = _index};
} forEach _items;

_control lbSetCurSel _restore;
