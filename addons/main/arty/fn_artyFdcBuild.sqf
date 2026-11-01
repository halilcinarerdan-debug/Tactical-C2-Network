/*
    Fonksiyon: TC2_fnc_artyFdcBuild
    Çalışma yeri: İstemci (uiOpen çağırır, pencere kurulurken)

    FDC sekmesinin kontrollerini kurar (varsayılan GİZLİ). FDC operatörü: gelen CFF'leri görür, batarya seçip MTO ile KABUL eder ya da REDDEDER,
    oyuncu bataryalarında SHOT / SPLASH / ROUNDS COMPLETE'i elle bildirir, CHECK FIRING verir.
    IDC: 92450 görev kuyruğu, 92451 CFF ayrıntısı, 92452 batarya, 92453 mermi, 92454 değişiklikler, 92455 KABUL, 92456 RED, 92457 red nedeni,
         92458 SHOT, 92459 SPLASH, 92460 ROUNDS COMPLETE, 92461 CHECK FIRING, 92462 durum, 92463 günlük, 92464 batarya bilgisi, 92550-92554 etiketler.

    Parametreler:
        0: pencere <DISPLAY>   1: sol   2: üst   3: genişlik   4: yükseklik   (içerik alanı)

    Dönüş: yok
*/

params ["_display", "_left", "_top", "_width", "_height"];

private _gap = 0.012;
private _colW = (_width - _gap) / 2;
private _labelW = 0.22;
private _rowH = (((_height - 0.01) / 11) min 0.04);

private _ids = [_display, _left, _top, _colW, _gap, _labelW, _rowH, [
    [0, 0, "GÖREV (KUYRUK)", 92550, [[92450, "combo", 1]]],
    [1, 0, "BATARYA", 92551, [[92452, "combo", 1]]],
    [1, 1, "MERMİ (0 = CFF)", 92552, [[92453, "edit", 1]]],
    [1, 2, "DEĞİŞİKLİKLER", 92553, [[92454, "edit", 1]]],
    [1, 4, "RED NEDENİ", 92554, [[92457, "edit", 1]]]
]] call TC2_fnc_uiBuildRows;

private _button = {
    params ["_display", "_idc", "_text", "_px", "_py", "_pw", "_ph", "_color"];
    private _control = [_display, _idc, "RscButtonMenu", _px, _py, _pw, _ph] call TC2_fnc_uiMakeControl;
    _control ctrlSetText _text;
    _control ctrlSetTextColor [0.25, 1, 0.35, 1];
    _control ctrlSetBackgroundColor _color;
    _control
};

private _rightX = _left + _colW + _gap;
private _half = (_colW - 0.006) / 2;
private _dark = [0.1, 0.45, 0.15, 1];
private _red = [0.45, 0.05, 0.05, 1];
private _grey = [0.02, 0.1, 0.03, 1];

private _accept = [_display, 92455, "KABUL (MTO)", _rightX, _top + 3 * _rowH, _half, _rowH - 0.004, _dark] call _button;
_accept ctrlAddEventHandler ["ButtonClick", {["ACCEPT"] call TC2_fnc_artyUiFdcAction}];
private _reject = [_display, 92456, "RED", _rightX + _half + 0.006, _top + 3 * _rowH, _half, _rowH - 0.004, _red] call _button;
_reject ctrlAddEventHandler ["ButtonClick", {["REJECT"] call TC2_fnc_artyUiFdcAction}];
private _shot = [_display, 92458, "SHOT", _rightX, _top + 5 * _rowH, _half, _rowH - 0.004, _grey] call _button;
_shot ctrlAddEventHandler ["ButtonClick", {["SHOT"] call TC2_fnc_artyUiFdcAction}];
private _splash = [_display, 92459, "SPLASH", _rightX + _half + 0.006, _top + 5 * _rowH, _half, _rowH - 0.004, _grey] call _button;
_splash ctrlAddEventHandler ["ButtonClick", {["SPLASH"] call TC2_fnc_artyUiFdcAction}];
private _complete = [_display, 92460, "ROUNDS COMPLETE", _rightX, _top + 6 * _rowH, _half, _rowH - 0.004, _grey] call _button;
_complete ctrlAddEventHandler ["ButtonClick", {["COMPLETE"] call TC2_fnc_artyUiFdcAction}];
private _check = [_display, 92461, "CHECK FIRING", _rightX + _half + 0.006, _top + 6 * _rowH, _half, _rowH - 0.004, _red] call _button;
_check ctrlAddEventHandler ["ButtonClick", {["CHECK"] call TC2_fnc_artyUiFdcAction}];

private _details = [_display, 92451, "RscStructuredText", _left, _top + _rowH, _colW, _rowH * 4 - 0.006] call TC2_fnc_uiMakeControl;
_details ctrlSetBackgroundColor [0, 0.05, 0.01, 1];
private _log = [_display, 92463, "RscStructuredText", _left, _top + 5 * _rowH, _colW, _rowH * 5] call TC2_fnc_uiMakeControl;
_log ctrlSetBackgroundColor [0, 0.05, 0.01, 1];
private _batteryInfo = [_display, 92464, "RscStructuredText", _rightX, _top + 7 * _rowH, _colW, _rowH * 3] call TC2_fnc_uiMakeControl;
_batteryInfo ctrlSetBackgroundColor [0, 0.05, 0.01, 1];

private _status = [_display, 92462, "RscText", _left, _top + 10 * _rowH + 0.006, _width, _rowH] call TC2_fnc_uiMakeControl;
_status ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
_status ctrlSetFontHeight (_rowH * 0.45);

(_display displayCtrl 92453) ctrlSetText "0";

missionNamespace setVariable ["TC2_arty_idsF", _ids + [92455, 92456, 92458, 92459, 92460, 92461, 92451, 92463, 92464, 92462]];
{
    (_display displayCtrl _x) ctrlAddEventHandler ["LBSelChanged", {call TC2_fnc_artyUiUpdate}];
} forEach [92450];
