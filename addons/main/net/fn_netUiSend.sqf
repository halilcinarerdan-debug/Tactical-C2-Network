/*
    Fonksiyon: TC2_fnc_netUiSend
    Çalışma yeri: İstemci (GÖNDER düğmesi / Enter)

    Mesaj kutusundaki metni gönderir ve kutuyu temizler.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

private _edit = _display displayCtrl 92031;
private _text = ctrlText _edit;

["MSG", _text] call TC2_fnc_netSend;
_edit ctrlSetText "";
