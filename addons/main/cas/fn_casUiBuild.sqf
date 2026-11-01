/*
    Fonksiyon: TC2_fnc_casUiBuild
    Çalışma yeri: İstemci (uiOpen çağırır, pencere kurulurken)

    CAS sekmesinin TEK EKRANLI 9-Line formunu kurar (iki sütun, doktrindeki satır sırası). Hepsi varsayılan GİZLİ;
    uiSelectTab yalnızca CAS sekmesinde gösterir (kontrol IDC listesi TC2_cas_ctrlIds'te).

    Sol sütun:  ALICI, KONTROL TÜRÜ + BOT/BOC, 1 IP/BP, 2 HEADING + OFFSET, 3 DISTANCE, 4 ELEVATION, 5 TANIM,
                6 KONUM (HARİTA sekmesindeki işaretlerden seçilir), 7 İŞARET + KOD, 8 DOST (m + yön)
    Sağ sütun:  9 EGRESS, REMARKS, KISITLAR (son saldırı yönü, ACA, danger close, TOT/TTT), sonuç alanı
    Alt:        GÖNDER, İPTAL (abort), durum satırı

    IDC: 92200-92219 form alanları, 92220 GÖNDER, 92221 İPTAL, 92222 sonuç metni, 92223 durum, 92300-92315 etiketler.

    Parametreler:
        0: pencere <DISPLAY>
        1: sol <NUMBER>   2: üst <NUMBER>   3: genişlik <NUMBER>   4: yükseklik <NUMBER>   (içerik alanı)

    Dönüş: yok
*/

params ["_display", "_left", "_top", "_width", "_height"];

private _green = [0.25, 1, 0.35, 1];
private _gap = 0.012;
private _colW = (_width - _gap) / 2;
private _labelW = 0.27;
private _rowH = (((_height - 0.01) / 11) min 0.04);
private _ids = [];

private _make = {
    params ["_display", "_idc", "_class", "_px", "_py", "_pw", "_ph"];
    private _control = _display ctrlCreate [_class, _idc];
    _control ctrlSetPosition [_px, _py, _pw, _ph];
    _control ctrlSetFontHeight (_ph * 0.72);
    _control ctrlShow false;
    _control ctrlCommit 0;
    _control
};

// [sütun, satır, etiket, etiket IDC, [[IDC, tür, genişlik oranı]]]
private _rows = [
    [0, 0, "ALICI (PİLOT)", 92300, [[92200, "combo", 1]]],
    [0, 1, "KONTROL / BOT-BOC", 92301, [[92201, "combo", 0.5], [92202, "combo", 0.5]]],
    [0, 2, "1  IP / BP", 92302, [[92203, "edit", 1]]],
    [0, 3, "2  HEADING / OFFSET", 92303, [[92204, "edit", 0.5], [92205, "combo", 0.5]]],
    [0, 4, "3  DISTANCE", 92304, [[92206, "edit", 1]]],
    [0, 5, "4  ELEVATION (ft MSL)", 92305, [[92207, "edit", 1]]],
    [0, 6, "5  HEDEF TANIMI", 92306, [[92208, "edit", 1]]],
    [0, 7, "6  HEDEF KONUMU", 92307, [[92209, "combo", 1]]],
    [0, 8, "7  İŞARET / KOD", 92308, [[92210, "combo", 0.5], [92211, "edit", 0.5]]],
    [0, 9, "8  DOST (m / YÖN)", 92309, [[92212, "edit", 0.5], [92213, "combo", 0.5]]],
    [1, 0, "9  EGRESS", 92310, [[92214, "edit", 1]]],
    [1, 1, "REMARKS", 92311, [[92215, "edit", 1]]],
    [1, 2, "KISIT SON SALDIRI YÖNÜ", 92312, [[92216, "edit", 1]]],
    [1, 3, "KISIT ACA", 92313, [[92217, "edit", 1]]],
    [1, 4, "KISIT DANGER CLOSE", 92314, [[92218, "edit", 1]]],
    [1, 5, "KISIT TOT / TTT", 92315, [[92219, "edit", 1]]]
];

{
    _x params ["_col", "_row", "_label", "_labelIdc", "_controls"];

    private _px = _left + _col * (_colW + _gap);
    private _py = _top + _row * _rowH;

    private _labelControl = [_display, _labelIdc, "RscText", _px, _py, _labelW, _rowH] call _make;
    _labelControl ctrlSetText _label;
    _labelControl ctrlSetTextColor [0.12, 0.6, 0.2, 1];
    _labelControl ctrlSetFontHeight (_rowH * 0.55);
    _ids pushBack _labelIdc;

    private _free = _colW - _labelW;
    private _offset = _labelW;

    {
        _x params ["_idc", "_kind", "_fraction"];
        private _control = [_display, _idc, if (_kind isEqualTo "combo") then {"RscCombo"} else {"RscEdit"}, _px + _offset, _py, _free * _fraction - 0.004, _rowH - 0.004] call _make;
        _control ctrlSetBackgroundColor [0, 0.08, 0.02, 1];
        _control ctrlSetTextColor _green;
        _offset = _offset + _free * _fraction;
        _ids pushBack _idc;
    } forEach _controls;
} forEach _rows;

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

[_display, 92200, [["— ağda hava aracı yok —", ""]]] call _fill;
[_display, 92201, [["TYPE 1", "1"], ["TYPE 2", "2"], ["TYPE 3", "3"]]] call _fill;
[_display, 92202, [["BOT", "BOT"], ["BOC", "BOC"]]] call _fill;
[_display, 92205, [["—", ""], ["SOL (L)", "L"], ["SAĞ (R)", "R"]]] call _fill;
[_display, 92209, [["— işaret seçin (HARİTA sekmesi) —", "-1"]]] call _fill;
[_display, 92210, [["YOK", "NONE"], ["DUMAN", "SMOKE"], ["LAZER", "LASER"], ["IR", "IR"]]] call _fill;
[_display, 92213, [["—", ""], ["N", "N"], ["NE", "NE"], ["E", "E"], ["SE", "SE"], ["S", "S"], ["SW", "SW"], ["W", "W"], ["NW", "NW"]]] call _fill;

(_display displayCtrl 92211) ctrlEnable false;

// Seçim değişince kuralları uygula (Type 1 => BOT, lazer => kod, işaret => yükseklik, alıcı => birim)
{
    (_display displayCtrl _x) ctrlAddEventHandler ["LBSelChanged", {call TC2_fnc_casUiChanged}];
} forEach [92200, 92201, 92209, 92210];

// Alt satır: GÖNDER, İPTAL, durum
private _bottom = _top + 10 * _rowH + 0.006;

private _sendButton = [_display, 92220, "RscButtonMenu", _left, _bottom, 0.18, _rowH] call _make;
_sendButton ctrlSetText "GÖNDER";
_sendButton ctrlSetTextColor _green;
_sendButton ctrlSetBackgroundColor [0.1, 0.45, 0.15, 1];
_sendButton ctrlAddEventHandler ["ButtonClick", {call TC2_fnc_casUiSend}];

private _abortButton = [_display, 92221, "RscButtonMenu", _left + 0.19, _bottom, 0.15, _rowH] call _make;
_abortButton ctrlSetText "İPTAL";
_abortButton ctrlSetTextColor [1, 0.6, 0.6, 1];
_abortButton ctrlSetBackgroundColor [0.45, 0.05, 0.05, 1];
_abortButton ctrlAddEventHandler ["ButtonClick", {call TC2_fnc_casUiAbort}];

private _status = [_display, 92223, "RscText", _left + 0.35, _bottom, _width - 0.35, _rowH] call _make;
_status ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
_status ctrlSetTextColor _green;
_status ctrlSetFontHeight (_rowH * 0.45);

// Geri okuma sonuç alanı (sağ sütun, alt)
private _results = [_display, 92222, "RscStructuredText", _left + _colW + _gap, _top + 6 * _rowH, _colW, _rowH * 4] call _make;
_results ctrlSetBackgroundColor [0, 0.05, 0.01, 1];

_ids append [92220, 92221, 92222, 92223];
missionNamespace setVariable ["TC2_cas_ctrlIds", _ids];
missionNamespace setVariable ["TC2_cas_sig", ""];
missionNamespace setVariable ["TC2_cas_statusText", ""];
