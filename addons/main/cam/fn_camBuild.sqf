/*
    Fonksiyon: TC2_fnc_camBuild
    Çalışma yeri: İstemci (uiOpen çağırır, pencere kurulurken)

    KAMERA sekmesinin kontrollerini kurar (varsayılan GİZLİ; camUiUpdate gösterir). YALNIZCA İZLEME: kontrol, bağlanma, silah, hedefleme yok.
      Üst:   kaynak listesi (İHA'lar ve kask kameraları) + görüntü modu düğmeleri (NORMAL / NVG / TERMAL; yalnızca izleyenin ekranını etkiler)
      Sol:   canlı görüntü (render-to-texture; yalnızca seçili kaynak varken render edilir)
      Sağ:   kaynağın durumu (tür, irtifa, hız, grid, yön) ve "yalnızca izleme" notu
      Alt:   durum satırı
    IDC: 92900 kaynak listesi, 92901 görüntü, 92902 bilgi, 92903-92905 mod düğmeleri, 92906 durum, 92907 görüntü zemini.

    Parametreler:
        0: pencere <DISPLAY>   1: sol   2: üst   3: genişlik   4: yükseklik   (içerik alanı)

    Dönüş: yok
*/

params ["_display", "_left", "_top", "_width", "_height"];

private _rowH = (((_height - 0.01) / 11) min 0.04);
private _green = [0.25, 1, 0.35, 1];
private _dark = [0.1, 0.45, 0.15, 1];

private _combo = [_display, 92900, "RscCombo", _left, _top, _width * 0.58, _rowH - 0.004] call TC2_fnc_uiMakeControl;
_combo ctrlSetBackgroundColor [0, 0.08, 0.02, 1];
_combo ctrlSetTextColor _green;
_combo lbAdd "— kamera kaynağı seçin —";
_combo lbSetData [0, ""];
_combo lbSetCurSel 0;
_combo ctrlAddEventHandler ["LBSelChanged", {call TC2_fnc_camUiChanged}];

private _modeW = (_width * 0.42 - 0.02) / 3;
{
    _x params ["_idc", "_text", "_index"];
    private _button = [_display, _idc, "RscButtonMenu", _left + _width * 0.58 + 0.01 + _index * (_modeW + 0.005), _top, _modeW, _rowH - 0.004] call TC2_fnc_uiMakeControl;
    _button ctrlSetText _text;
    _button ctrlSetTextColor _green;
    _button ctrlSetBackgroundColor _dark;
    _button setVariable ["tc2_mode", _index];
    _button ctrlAddEventHandler ["ButtonClick", {[(_this select 0) getVariable ["tc2_mode", 0]] call TC2_fnc_camUiMode}];
} forEach [[92903, "NORMAL", 0], [92904, "NVG", 1], [92905, "TERMAL", 2]];

// Görüntü: ekran kenarı zemini + render-to-texture resmi. Alan, durum satırına kadar uzanır; genişlik içeriğin ~%74'ü (bilgi paneli dar kalır).
// Doku 2:1; resmin gerçek piksel oranı hesaplanır ve r2t'ye verilir (görüntü gerilmez).
private _picH = 9 * _rowH - 0.012;
private _picW = _width * 0.74;
missionNamespace setVariable ["TC2_cam_aspect", (_picW / _picH) * (safeZoneH / safeZoneW) * (getResolution select 4)];
private _picTop = _top + _rowH + 0.006;

private _background = [_display, 92907, "RscText", _left, _picTop, _picW + 0.01, _picH + 0.01] call TC2_fnc_uiMakeControl;
_background ctrlSetBackgroundColor [0.01, 0.015, 0.01, 1];

private _picture = [_display, 92901, "RscPicture", _left + 0.005, _picTop + 0.005, _picW, _picH] call TC2_fnc_uiMakeControl;
_picture ctrlSetText "";

private _info = [_display, 92902, "RscStructuredText", _left + _picW + 0.025, _picTop, _width - _picW - 0.025, _picH + 0.01] call TC2_fnc_uiMakeControl;
_info ctrlSetBackgroundColor [0, 0.05, 0.01, 1];

private _status = [_display, 92906, "RscText", _left, _top + 10 * _rowH + 0.006, _width, _rowH] call TC2_fnc_uiMakeControl;
_status ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
_status ctrlSetTextColor _green;
_status ctrlSetFontHeight (_rowH * 0.45);

missionNamespace setVariable ["TC2_cam_data", ["EMPTY", 1, false, [], ""]];
missionNamespace setVariable ["TC2_cam_reqTime", -1];
missionNamespace setVariable ["TC2_cam_sig", ""];
missionNamespace setVariable ["TC2_cam_current", ""];
missionNamespace setVariable ["TC2_cam_statusText", ""];
missionNamespace setVariable ["TC2_cam_mode", 0];
