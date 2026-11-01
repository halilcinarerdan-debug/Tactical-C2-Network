/*
    Fonksiyon: TC2_fnc_medBuild
    Çalışma yeri: İstemci (uiOpen çağırır, pencere kurulurken)

    MEDEVAC sekmesinin kontrollerini kurar (varsayılan GİZLİ; medUiUpdate gösterir).
      Sol:  9-Line MEDEVAC formu (9 satır), TALEBİ GÖNDER
      Sağ:  ağdaki talepler listesi, seçili talebin 9 satırı + durumu, TALEBİ İPTAL ET
      Alt:  durum satırı
    IDC: 92800 talepler, 92801 ayrıntı, 92802 İPTAL, 92803 GÖNDER, 92804 durum,
         92810 alım yeri, 92811 ek not, 92812-92816 hasta sayıları (A-E), 92817 ekipman, 92818 sedyeli, 92819 yürüyebilen,
         92820 güvenlik, 92821 işaretleme, 92822 uyruk, 92823 CBRN, 92830-92838 etiketler.

    Parametreler:
        0: pencere <DISPLAY>   1: sol   2: üst   3: genişlik   4: yükseklik   (içerik alanı)

    Dönüş: yok
*/

params ["_display", "_left", "_top", "_width", "_height"];

private _rowH = (((_height - 0.01) / 11) min 0.04);
private _dark = [0.1, 0.45, 0.15, 1];
private _green = [0.25, 1, 0.35, 1];

private _leftW = _width * 0.52;
private _rightX = _left + _leftW + 0.02;
private _rightW = _width - _leftW - 0.02;

private _rows = [
    [0, 0, "1  Alım yeri", 92830, [[92810, "combo", 1]]],
    [0, 1, "2  Ek not", 92831, [[92811, "edit", 1]]],
    [0, 2, "3  Hasta/öncelik", 92832, [[92812, "combo", 0.2], [92813, "combo", 0.2], [92814, "combo", 0.2], [92815, "combo", 0.2], [92816, "combo", 0.2]]],
    [0, 3, "4  Özel ekipman", 92833, [[92817, "combo", 1]]],
    [0, 4, "5  Hasta tipi", 92834, [[92818, "combo", 0.5], [92819, "combo", 0.5]]],
    [0, 5, "6  Güvenlik", 92835, [[92820, "combo", 1]]],
    [0, 6, "7  İşaretleme", 92836, [[92821, "combo", 1]]],
    [0, 7, "8  Uyruk/durum", 92837, [[92822, "combo", 1]]],
    [0, 8, "9  CBRN", 92838, [[92823, "combo", 1]]]
];
[_display, _left, _top, _leftW, 0, 0.17, _rowH, _rows] call TC2_fnc_uiBuildRows;

private _fill = {
    params ["_idc", "_items"];
    private _control = _display displayCtrl _idc;
    {
        private _index = _control lbAdd (_x select 0);
        _control lbSetData [_index, _x select 1];
    } forEach _items;
    _control lbSetCurSel 0;
};

[92810, [["Kendi konumum", "OWN"]]] call _fill;

private _numbers = {
    params ["_prefix"];
    private _items = [];
    for "_n" from 0 to 9 do {_items pushBack [format ["%1 %2", _prefix, _n], str _n]};
    _items
};
{
    [92812 + _forEachIndex, [_x] call _numbers] call _fill;
} forEach ["A", "B", "C", "D", "E"];

[92817, [["A  yok", "A"], ["B  vinç", "B"], ["C  kurtarma ekipmanı", "C"], ["D  ventilatör", "D"]]] call _fill;
[92818, ["L sedye"] call _numbers] call _fill;
[92819, ["A yürüyebilen"] call _numbers] call _fill;
[92820, [["N  düşman yok", "N"], ["P  olası düşman", "P"], ["E  düşman var", "E"], ["X  silahlı eskort şart", "X"]]] call _fill;
[92821, [["A  panel", "A"], ["B  piroteknik", "B"], ["C  duman", "C"], ["D  yok", "D"], ["E  diğer", "E"]]] call _fill;
[92822, [["A  dost asker", "A"], ["B  dost sivil", "B"], ["C  dost dışı asker", "C"], ["D  dost dışı sivil", "D"], ["E  düşman esir", "E"]]] call _fill;
[92823, [["yok", ""], ["N  nükleer", "N"], ["B  biyolojik", "B"], ["C  kimyasal", "C"]]] call _fill;

private _button = {
    params ["_idc", "_text", "_px", "_py", "_pw", "_color", "_code"];
    private _control = [_display, _idc, "RscButtonMenu", _px, _py, _pw, _rowH - 0.004] call TC2_fnc_uiMakeControl;
    _control ctrlSetText _text;
    _control ctrlSetTextColor _green;
    _control ctrlSetBackgroundColor _color;
    _control ctrlAddEventHandler ["ButtonClick", _code];
    _control
};

[92803, "TALEBİ GÖNDER", _left, _top + 9 * _rowH, _leftW, _dark, {call TC2_fnc_medUiSend}] call _button;

// Sağ: talepler
private _inbox = [_display, 92800, "RscCombo", _rightX, _top, _rightW, _rowH - 0.004] call TC2_fnc_uiMakeControl;
_inbox ctrlSetBackgroundColor [0, 0.08, 0.02, 1];
_inbox ctrlSetTextColor _green;
_inbox lbAdd "— talepler —";
_inbox lbSetData [0, ""];
_inbox lbSetCurSel 0;
_inbox ctrlAddEventHandler ["LBSelChanged", {call TC2_fnc_medUiUpdate}];

private _details = [_display, 92801, "RscStructuredText", _rightX, _top + _rowH, _rightW, _rowH * 7.4] call TC2_fnc_uiMakeControl;
_details ctrlSetBackgroundColor [0, 0.05, 0.01, 1];

[92802, "TALEBİ İPTAL ET", _rightX, _top + 8.6 * _rowH, _rightW, [0.35, 0.08, 0.05, 1], {call TC2_fnc_medUiCancel}] call _button;

private _status = [_display, 92804, "RscText", _left, _top + 10 * _rowH + 0.006, _width, _rowH] call TC2_fnc_uiMakeControl;
_status ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
_status ctrlSetTextColor _green;
_status ctrlSetFontHeight (_rowH * 0.45);

missionNamespace setVariable ["TC2_med_data", ["EMPTY", 1, false, []]];
missionNamespace setVariable ["TC2_med_statusText", ""];
missionNamespace setVariable ["TC2_med_sig", ""];
missionNamespace setVariable ["TC2_med_detailText", ""];
