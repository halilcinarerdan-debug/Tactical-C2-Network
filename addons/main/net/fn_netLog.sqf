/*
    Fonksiyon: TC2_fnc_netLog
    Çalışma yeri: İstemci

    Ağ günlüğüne (ekranın altındaki liste) zaman damgalı bir satır ekler; son 8 satır tutulur.
    Metin zaten temizlenmiş olmalıdır ('<', '>' içermez).

    Parametreler:
        0: metin <STRING>
        1: renk <STRING>  örn. "#40ff59"

    Dönüş: yok
*/

params [["_text", "", [""]], ["_color", "#40ff59", [""]]];

private _date = date;
private _hour = _date select 3;
private _minute = _date select 4;
private _stamp = format [
    "%1:%2",
    if (_hour < 10) then {format ["0%1", _hour]} else {str _hour},
    if (_minute < 10) then {format ["0%1", _minute]} else {str _minute}
];

private _log = missionNamespace getVariable ["TC2_net_log", []];
_log pushBack format ["<t color='#1f9930'>%1</t> <t color='%2'>%3</t>", _stamp, _color, _text];

while {count _log > 8} do {_log deleteAt 0};

missionNamespace setVariable ["TC2_net_log", _log];

call TC2_fnc_netUiUpdate;
