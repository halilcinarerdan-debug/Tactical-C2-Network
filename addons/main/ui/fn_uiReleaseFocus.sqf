/*
    Fonksiyon: TC2_fnc_uiReleaseFocus
    Çalışma yeri: İstemci (terminal ve pilot pencerelerinin "MouseButtonDown" olayı)

    Sorun: yazı kutusuna (RscEdit) tıklanınca klavye odağı kutuda kalıyor ve başka yere tıklamak zorlaşıyordu.
    Çözüm: YALNIZCA o an odakta bir yazı kutusu varsa (uiTrackFocus ile izlenir: TC2_ui_focusIdc) ve sol tık o kutunun DIŞINDAYSA,
    odağı görünmez bir "odak çukuru" düğmesine ver. Odakta yazı kutusu yoksa hiçbir şey yapılmaz (önceki sürüm her tıklamada odağı
    çalıyordu).

    Parametreler:
        0: pencere <DISPLAY>
        1: fare x <NUMBER>
        2: fare y <NUMBER>
        3: yazı kutusu IDC listesi <ARRAY>
        4: odak verilecek düğme IDC <NUMBER>  (terminalde 92005 görünmez çukur; pilot penceresinde GERİ OKU)

    Dönüş: yok
*/

params ["_display", "_mx", "_my", "_editIdcs", "_focusIdc"];

private _idc = missionNamespace getVariable ["TC2_ui_focusIdc", -1];
if (_idc < 0 || {!(_idc in _editIdcs)}) exitWith {};

private _focused = _display displayCtrl _idc;
if (isNull _focused) exitWith {};

(ctrlPosition _focused) params ["_cx", "_cy", "_cw", "_ch"];
if (_mx >= _cx && {_mx <= _cx + _cw} && {_my >= _cy} && {_my <= _cy + _ch}) exitWith {};

ctrlSetFocus (_display displayCtrl _focusIdc);
