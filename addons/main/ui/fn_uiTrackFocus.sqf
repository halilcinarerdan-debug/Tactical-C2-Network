/*
    Fonksiyon: TC2_fnc_uiTrackFocus
    Çalışma yeri: İstemci (uiOpen ve casPilotOpen, pencere kurulduktan sonra)

    Yazı kutularının odak durumunu izler: odak alınca TC2_ui_focusIdc = IDC, odak bırakılınca -1.
    (Arma'da "odaktaki kontrol" okuyan güvenilir bir komut yoktur; bu yüzden olaylarla izlenir. uiReleaseFocus bunu kullanır.)

    Parametreler:
        0: pencere <DISPLAY>
        1: yazı kutusu IDC listesi <ARRAY>

    Dönüş: yok
*/

params ["_display", "_idcs"];

missionNamespace setVariable ["TC2_ui_focusIdc", -1];

{
    private _control = _display displayCtrl _x;
    if (!isNull _control) then {
        _control ctrlAddEventHandler ["SetFocus", {
            missionNamespace setVariable ["TC2_ui_focusIdc", ctrlIDC (_this select 0)];
        }];
        _control ctrlAddEventHandler ["KillFocus", {
            if ((missionNamespace getVariable ["TC2_ui_focusIdc", -1]) == ctrlIDC (_this select 0)) then {
                missionNamespace setVariable ["TC2_ui_focusIdc", -1];
            };
        }];
    };
} forEach _idcs;
