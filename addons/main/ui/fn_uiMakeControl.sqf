/*
    Fonksiyon: TC2_fnc_uiMakeControl
    Çalışma yeri: İstemci

    Terminal penceresinde bir kontrol yaratır; varsayılan GİZLİ (ilgili sekme göstermeden görünmez), yazı boyutu yüksekliğe göre.

    Parametreler:
        0: pencere <DISPLAY>   1: IDC <NUMBER>   2: sınıf <STRING> (RscText, RscEdit, RscCombo, RscButtonMenu, RscStructuredText)
        3: x   4: y   5: genişlik   6: yükseklik <NUMBER>

    Dönüş: kontrol <CONTROL>
*/

params ["_display", "_idc", "_class", "_px", "_py", "_pw", "_ph"];

private _control = _display ctrlCreate [_class, _idc];
_control ctrlSetPosition [_px, _py, _pw, _ph];
_control ctrlSetFontHeight (_ph * 0.72);
_control ctrlShow false;
_control ctrlCommit 0;

_control
