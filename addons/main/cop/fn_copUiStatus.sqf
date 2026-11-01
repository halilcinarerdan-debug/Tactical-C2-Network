/*
    Fonksiyon: TC2_fnc_copUiStatus
    Çalışma yeri: İstemci

    HARİTA sekmesinin durum satırını (92043) yazar. Pencere kapalıysa bir şey yapmaz.

    Parametreler:
        0: metin <STRING>
        1: renk <ARRAY>  [r,g,b,a]

    Dönüş: yok
*/

params [["_text", "", [""]], ["_color", [0.25, 1, 0.35, 1], [[]]]];

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

private _control = _display displayCtrl 92043;
_control ctrlSetText _text;
_control ctrlSetTextColor _color;
