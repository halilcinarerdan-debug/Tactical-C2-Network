/*
    Fonksiyon: TC2_fnc_casPilotOpen
    Çalışma yeri: İSTEMCİ PİLOT (ACE self menüsü "CAS 9-Line" eylemi; uçak içinde de çalışır)

    Gelen 9-Line penceresini açar: solda doktrindeki 9 satır + remarks/kısıtlar, sağda ZORUNLU GERİ OKUMA alanları
    (satır 4 yükseklik, satır 6 konum ve verilmiş kısıtlar) ve sonuç. Modal diyalog: açıkken tuşlar pencereye gider
    (uçuş kontrolü dahil); pencereyi uçuş sakinken açın / ikinci pilot kullanın.

    IDC: 92101 arka plan, 92102 başlık, 92103 KAPAT, 92104 satırlar, 92110-92115 geri okuma kutuları,
         92116 GERİ OKU, 92117 sonuç, 92120-92125 etiketler.

    Parametreler: yok
    Dönüş: yok
*/

if (count (missionNamespace getVariable ["TC2_cas_incoming", []]) == 0) exitWith {};
if (!isNull findDisplay 92100) exitWith {};
if (!createDialog "TC2_CasDialog") exitWith {diag_log "[TC2][CAS] createDialog TC2_CasDialog basarisiz."};

private _display = findDisplay 92100;
if (isNull _display) exitWith {};

private _green = [0.25, 1, 0.35, 1];
private _w = 0.64 * safeZoneW;
private _h = 0.66 * safeZoneH;
private _left = safeZoneX + (safeZoneW - _w) / 2;
private _top = safeZoneY + (safeZoneH - _h) / 2;
private _headerH = 0.05;
private _pad = 0.015;
private _rowH = 0.04;
private _closeW = 0.14;

private _background = _display ctrlCreate ["RscText", 92101];
_background ctrlSetPosition [_left, _top, _w, _h];
_background ctrlSetBackgroundColor [0, 0.04, 0, 0.95];
_background ctrlCommit 0;

private _header = _display ctrlCreate ["RscText", 92102];
_header ctrlSetPosition [_left, _top, _w - _closeW, _headerH];
_header ctrlSetBackgroundColor [0, 0.2, 0.05, 1];
_header ctrlSetTextColor _green;
_header ctrlSetText "  CAS 9-LINE";
_header ctrlSetFontHeight 0.032;
_header ctrlCommit 0;

private _close = _display ctrlCreate [["RscButtonMenu"] call TC2_fnc_uiClass, 92103];
_close ctrlSetPosition [_left + _w - _closeW, _top, _closeW, _headerH];
_close ctrlSetText "KAPAT";
_close ctrlSetBackgroundColor [0.45, 0.05, 0.05, 1];
_close ctrlSetTextColor [1, 1, 1, 1];
_close ctrlAddEventHandler ["ButtonClick", {(ctrlParent (_this select 0)) closeDisplay 2}];
_close ctrlCommit 0;

// Sol: 9-Line
private _linesWidth = _w * 0.55;
private _lines = _display ctrlCreate [["RscStructuredText"] call TC2_fnc_uiClass, 92104];
_lines ctrlSetPosition [_left + _pad, _top + _headerH + _pad, _linesWidth, _h - _headerH - 2 * _pad];
_lines ctrlSetBackgroundColor [0, 0, 0, 0];
_lines ctrlCommit 0;

// Sağ: geri okuma
private _rightLeft = _left + _linesWidth + 2 * _pad;
private _rightWidth = _w - _linesWidth - 3 * _pad;
private _labelWidth = _rightWidth * 0.5;
private _fields = [
    [0, "SATIR 4 YÜKSEKLİK (ft)", 92110, 92120],
    [1, "SATIR 6 KONUM", 92111, 92121],
    [2, "KISIT SON SALDIRI YÖNÜ", 92112, 92122],
    [3, "KISIT DANGER CLOSE", 92113, 92123],
    [4, "KISIT ACA", 92114, 92124],
    [5, "KISIT TOT / TTT", 92115, 92125]
];
{
    _x params ["_row", "_label", "_editIdc", "_labelIdc"];
    private _y = _top + _headerH + _pad + _row * (_rowH + 0.006);

    private _labelControl = _display ctrlCreate ["RscText", _labelIdc];
    _labelControl ctrlSetPosition [_rightLeft, _y, _labelWidth, _rowH];
    _labelControl ctrlSetText _label;
    _labelControl ctrlSetTextColor [0.12, 0.6, 0.2, 1];
    _labelControl ctrlSetFontHeight (_rowH * 0.5);
    _labelControl ctrlCommit 0;

    private _edit = _display ctrlCreate ["RscEdit", _editIdc];
    _edit ctrlSetPosition [_rightLeft + _labelWidth, _y, _rightWidth - _labelWidth, _rowH];
    _edit ctrlSetBackgroundColor [0, 0.08, 0.02, 1];
    _edit ctrlSetTextColor _green;
    _edit ctrlSetFontHeight (_rowH * 0.7);
    _edit ctrlCommit 0;
} forEach _fields;

private _buttonY = _top + _headerH + _pad + 6 * (_rowH + 0.006) + 0.01;

private _readback = _display ctrlCreate [["RscButtonMenu"] call TC2_fnc_uiClass, 92116];
_readback ctrlSetPosition [_rightLeft, _buttonY, _rightWidth, _rowH + 0.005];
_readback ctrlSetText "GERİ OKU";
_readback ctrlSetTextColor _green;
_readback ctrlSetBackgroundColor [0.1, 0.45, 0.15, 1];
_readback ctrlAddEventHandler ["ButtonClick", {call TC2_fnc_casPilotReadback}];
_readback ctrlCommit 0;

private _resultY = _buttonY + _rowH + 0.02;
private _results = _display ctrlCreate [["RscStructuredText"] call TC2_fnc_uiClass, 92117];
_results ctrlSetPosition [_rightLeft, _resultY, _rightWidth, (_top + _h - _pad) - _resultY];
_results ctrlSetBackgroundColor [0, 0.05, 0.01, 1];
_results ctrlCommit 0;

// ESC: duraklatma menüsü açılmasın, pencere kapansın.
_display displayAddEventHandler ["KeyDown", {
    params ["_display", "_key"];
    if (_key == 1) exitWith {
        _display closeDisplay 2;
        true
    };
    false
}];

// Yazı kutularının odağını izle ve dışına sol tık: klavye odağını kutudan al (bkz. uiTrackFocus / uiReleaseFocus).
[_display, [92110, 92111, 92112, 92113, 92114, 92115]] call TC2_fnc_uiTrackFocus;
_display displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_mx", "_my"];
    if (_button != 0) exitWith {};
    [_display, _mx, _my, [92110, 92111, 92112, 92113, 92114, 92115], 92116] call TC2_fnc_uiReleaseFocus;
}];

// Kapanınca: tamamlanmış (doğru geri okuma) ya da iptal edilmiş talebi temizle -> ACE eylemi kaybolur.
_display displayAddEventHandler ["Unload", {
    private _incoming = missionNamespace getVariable ["TC2_cas_incoming", []];
    if (count _incoming > 0 && {(_incoming select 5) in ["READBACK_OK", "ABORTED"]}) then {
        missionNamespace setVariable ["TC2_cas_incoming", []];
    };
}];

call TC2_fnc_casPilotUpdate;

// Yazı tipi: EtelkaMonospacePro (CBA TC2_ui_mono açıksa).
[_display] call TC2_fnc_uiFontApply;
