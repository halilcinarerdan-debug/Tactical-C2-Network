/*
    Fonksiyon: TC2_fnc_uiBuildRows
    Çalışma yeri: İstemci

    Etiket + kontrol satırlarını iki sütunlu bir ızgarada kurar (form sekmeleri için ortak yardımcı). Her satır:
        [sütun, satır, etiket, etiket IDC, [[IDC, tür ("combo" | "edit"), genişlik oranı]]]
    Kontroller varsayılan gizli, yeşil/siyah tema.

    Parametreler:
        0: pencere <DISPLAY>   1: sol   2: üst   3: sütun genişliği   4: sütun aralığı   5: etiket genişliği   6: satır yüksekliği
        7: satırlar <ARRAY>

    Dönüş: oluşturulan IDC listesi <ARRAY>
*/

params ["_display", "_left", "_top", "_colW", "_gap", "_labelW", "_rowH", "_rows"];

private _ids = [];

{
    _x params ["_col", "_row", "_label", "_labelIdc", "_controls"];

    private _px = _left + _col * (_colW + _gap);
    private _py = _top + _row * _rowH;

    private _labelControl = [_display, _labelIdc, "RscText", _px, _py, _labelW, _rowH] call TC2_fnc_uiMakeControl;
    _labelControl ctrlSetText _label;
    _labelControl ctrlSetTextColor [0.12, 0.6, 0.2, 1];
    _labelControl ctrlSetFontHeight (_rowH * 0.55);
    _ids pushBack _labelIdc;

    private _free = _colW - _labelW;
    private _offset = _labelW;

    {
        _x params ["_idc", "_kind", "_fraction"];
        private _control = [_display, _idc, if (_kind isEqualTo "combo") then {"RscCombo"} else {"RscEdit"}, _px + _offset, _py, _free * _fraction - 0.004, _rowH - 0.004] call TC2_fnc_uiMakeControl;
        _control ctrlSetBackgroundColor [0, 0.08, 0.02, 1];
        _control ctrlSetTextColor [0.25, 1, 0.35, 1];
        _offset = _offset + _free * _fraction;
        _ids pushBack _idc;
    } forEach _controls;
} forEach _rows;

_ids
