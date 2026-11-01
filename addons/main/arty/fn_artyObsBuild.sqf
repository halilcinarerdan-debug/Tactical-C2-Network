/*
    Fonksiyon: TC2_fnc_artyObsBuild
    Çalışma yeri: İstemci (uiOpen çağırır, pencere kurulurken)

    TOPÇU (gözlemci) sekmesinin kontrollerini kurar; hepsi varsayılan GİZLİ, artyUiUpdate gösterir.
      PANEL A  yeni CFF formu (ATP 3-09.30, bölüm 4): FDC, görev türü, konum yöntemi (GRID / POLAR / SHIFT), hedef tanımı, koruma,
               angajman yöntemi (düzeltme türü, DANGER CLOSE, MARK, yörünge, mühimmat, hacim), ateş ve kontrol yöntemi, süre. GÖNDER.
      PANEL B  görev denetimi (görev başladıktan sonra): özet + günlük (MTO, SHOT, SPLASH, ROUNDS COMPLETE), düzeltmeler
               (DIRECTION, LEFT/RIGHT, ADD/DROP, UP/DOWN, ADJUST/FFE, DANGER CLOSE), REPEAT, FIRE (AT MY COMMAND), CHECK FIRING, END OF MISSION.
    IDC: 92400-92418 panel A alanları (92419 GÖNDER), 92430-92435 panel B alanları, 92436-92443 düğmeler, 92440/92441 EOM, 92444 özet, 92445 günlük,
         92420 durum satırı, 92500-92517 / 92530-92538 etiketler.

    Parametreler:
        0: pencere <DISPLAY>   1: sol   2: üst   3: genişlik   4: yükseklik   (içerik alanı)

    Dönüş: yok
*/

params ["_display", "_left", "_top", "_width", "_height"];

private _green = [0.25, 1, 0.35, 1];
private _gap = 0.012;
private _colW = (_width - _gap) / 2;
private _labelW = 0.22;
private _rowH = (((_height - 0.01) / 11) min 0.04);

private _idsA = [_display, _left, _top, _colW, _gap, _labelW, _rowH, [
    [0, 0, "FDC (ALICI)", 92500, [[92400, "combo", 1]]],
    [0, 1, "GÖREV", 92501, [[92401, "combo", 1]]],
    [0, 2, "KONUM YÖNTEMİ", 92502, [[92402, "combo", 1]]],
    [0, 3, "HEDEF / NOKTA", 92503, [[92408, "combo", 1]]],
    [0, 4, "F1", 92504, [[92403, "edit", 1]]],
    [0, 5, "F2", 92505, [[92404, "edit", 1]]],
    [0, 6, "F3", 92506, [[92405, "edit", 1]]],
    [0, 7, "F4", 92507, [[92406, "edit", 1]]],
    [0, 8, "HEDEF TANIMI", 92508, [[92409, "edit", 1]]],
    [0, 9, "KORUMA", 92509, [[92410, "combo", 1]]],
    [1, 0, "DÜZELTME TÜRÜ", 92510, [[92411, "combo", 1]]],
    [1, 1, "DANGER CLOSE", 92511, [[92412, "combo", 1]]],
    [1, 2, "MARK", 92512, [[92413, "combo", 1]]],
    [1, 3, "YÖRÜNGE", 92513, [[92414, "combo", 1]]],
    [1, 4, "MÜHİMMAT", 92514, [[92415, "combo", 1]]],
    [1, 5, "HACİM (mermi/top)", 92515, [[92416, "edit", 1]]],
    [1, 6, "KONTROL", 92516, [[92417, "combo", 1]]],
    [1, 7, "SÜRE (sn)", 92517, [[92418, "edit", 1]]]
]] call TC2_fnc_uiBuildRows;

private _idsB = [_display, _left, _top, _colW, _gap, _labelW, _rowH, [
    [1, 0, "DİREKSİYON (mil)", 92530, [[92430, "edit", 1]]],
    [1, 1, "SOL(-) / SAĞ(+) m", 92531, [[92431, "edit", 1]]],
    [1, 2, "DROP(-) / ADD(+) m", 92532, [[92432, "edit", 1]]],
    [1, 3, "DOWN(-) / UP(+) m", 92533, [[92433, "edit", 1]]],
    [1, 4, "YENİ GÖREV", 92534, [[92434, "combo", 1]]],
    [1, 5, "DANGER CLOSE", 92535, [[92435, "combo", 1]]],
    [1, 8, "EOM / KAYIT", 92538, [[92440, "edit", 0.6], [92441, "combo", 0.4]]]
]] call TC2_fnc_uiBuildRows;

// Düğme yardımcısı
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

private _send = [_display, 92419, "GÖNDER (CFF)", _left, _top + 10 * _rowH + 0.006, 0.2, _rowH, _dark] call _button;
_send ctrlAddEventHandler ["ButtonClick", {call TC2_fnc_artyUiSend}];

private _correct = [_display, 92436, "DÜZELT", _rightX, _top + 6 * _rowH, _half, _rowH - 0.004, _dark] call _button;
_correct ctrlAddEventHandler ["ButtonClick", {["CORRECT"] call TC2_fnc_artyUiObsAction}];
private _repeat = [_display, 92437, "REPEAT", _rightX + _half + 0.006, _top + 6 * _rowH, _half, _rowH - 0.004, _dark] call _button;
_repeat ctrlAddEventHandler ["ButtonClick", {["REPEAT"] call TC2_fnc_artyUiObsAction}];
private _fire = [_display, 92438, "FIRE (AMC)", _rightX, _top + 7 * _rowH, _half, _rowH - 0.004, _dark] call _button;
_fire ctrlAddEventHandler ["ButtonClick", {["FIRE"] call TC2_fnc_artyUiObsAction}];
private _check = [_display, 92439, "CHECK FIRING", _rightX + _half + 0.006, _top + 7 * _rowH, _half, _rowH - 0.004, _red] call _button;
_check ctrlAddEventHandler ["ButtonClick", {["CHECK"] call TC2_fnc_artyUiObsAction}];
private _eom = [_display, 92442, "END OF MISSION", _rightX, _top + 9 * _rowH, _half, _rowH - 0.004, _dark] call _button;
_eom ctrlAddEventHandler ["ButtonClick", {["EOM"] call TC2_fnc_artyUiObsAction}];
private _new = [_display, 92443, "YENİ GÖREV", _rightX + _half + 0.006, _top + 9 * _rowH, _half, _rowH - 0.004, [0.02, 0.1, 0.03, 1]] call _button;
_new ctrlAddEventHandler ["ButtonClick", {
    missionNamespace setVariable ["TC2_arty_forceNew", true];
    call TC2_fnc_artyUiUpdate;
}];

// Özet ve günlük (panel B, sol sütun)
private _info = [_display, 92444, "RscStructuredText", _left, _top, _colW, _rowH * 3] call TC2_fnc_uiMakeControl;
_info ctrlSetBackgroundColor [0, 0.05, 0.01, 1];
private _log = [_display, 92445, "RscStructuredText", _left, _top + 3 * _rowH + 0.006, _colW, _rowH * 7 - 0.006] call TC2_fnc_uiMakeControl;
_log ctrlSetBackgroundColor [0, 0.05, 0.01, 1];

private _status = [_display, 92420, "RscText", _left + 0.21, _top + 10 * _rowH + 0.006, _width - 0.21, _rowH] call TC2_fnc_uiMakeControl;
_status ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
_status ctrlSetFontHeight (_rowH * 0.45);

// Seçenek listeleri
private _fill = {
    params ["_display", "_idc", "_items"];
    private _control = _display displayCtrl _idc;
    {
        private _index = _control lbAdd (_x select 0);
        _control lbSetData [_index, _x select 1];
    } forEach _items;
    _control lbSetCurSel 0;
};

[_display, 92400, [["— ağda FDC yok —", ""]]] call _fill;
[_display, 92401, [["ADJUST FIRE", "ADJUST"], ["FIRE FOR EFFECT", "FFE"], ["SUPPRESS", "SUPPRESS"], ["IMMEDIATE SUPPRESSION", "IMM_SUPP"], ["IMMEDIATE SMOKE", "IMM_SMOKE"]]] call _fill;
[_display, 92402, [["GRID (işaretten)", "GRID"], ["POLAR", "POLAR"], ["SHIFT (bilinen noktadan)", "SHIFT"]]] call _fill;
[_display, 92408, [["— işaret seçin —", ""]]] call _fill;
[_display, 92410, [["AÇIKTA", "OPEN"], ["SİPERDE", "DUGIN"], ["ÜSTÜ KAPALI SIĞINAKTA", "BUNKER"]]] call _fill;
[_display, 92411, [["ALAN", "AREA"], ["HASSAS (DESTRUCTION)", "PRECISION"]]] call _fill;
[_display, 92412, [["YOK", "0"], ["VAR", "1"]]] call _fill;
[_display, 92413, [["YOK", "0"], ["VAR", "1"]]] call _fill;
[_display, 92414, [["ALÇAK AÇI", "LOW"], ["YÜKSEK AÇI", "HIGH"]]] call _fill;
[_display, 92415, [["HE", "HE"], ["SMOKE", "SMOKE"], ["WP", "WP"], ["ILLUM", "ILLUM"]]] call _fill;
[_display, 92417, [["FIRE WHEN READY", "FWR"], ["AT MY COMMAND", "AMC"], ["CANNOT OBSERVE", "CANNOT_OBSERVE"]]] call _fill;
[_display, 92434, [["AYNI GÖREV", ""], ["ADJUST FIRE", "ADJUST"], ["FIRE FOR EFFECT", "FFE"]]] call _fill;
[_display, 92435, [["AYNI", "0"], ["DANGER CLOSE VAR", "1"], ["DANGER CLOSE İPTAL", "2"]]] call _fill;
[_display, 92441, [["KAYIT YOK", "0"], ["RECORD AS TARGET", "1"]]] call _fill;

(_display displayCtrl 92416) ctrlSetText "1";
(_display displayCtrl 92418) ctrlSetText "0";

{
    (_display displayCtrl _x) ctrlAddEventHandler ["LBSelChanged", {call TC2_fnc_artyUiChanged}];
} forEach [92401, 92402];

missionNamespace setVariable ["TC2_arty_idsA", _idsA + [92419]];
missionNamespace setVariable ["TC2_arty_idsB", _idsB + [92436, 92437, 92438, 92439, 92442, 92443, 92444, 92445]];
missionNamespace setVariable ["TC2_arty_forceNew", false];
missionNamespace setVariable ["TC2_arty_statusText", ""];
missionNamespace setVariable ["TC2_arty_sig", ""];
