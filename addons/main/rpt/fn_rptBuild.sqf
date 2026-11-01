/*
    Fonksiyon: TC2_fnc_rptBuild
    Çalışma yeri: İstemci (uiOpen çağırır, pencere kurulurken)

    RAPOR sekmesinin kontrollerini kurar (hepsi varsayılan GİZLİ; rptUiUpdate gösterir).
      Sol:  rapor türü (SALUTE / SITREP / LACE), türe göre form satırları, GÖNDER
      Sağ:  gelen raporlar listesi, seçili raporun ayrıntısı, DOĞRULA (S2 / CO; yalnızca SALUTE)
      Alt:  durum satırı
    IDC: 92700 tür, 92710-92713 LACE durumları, 92716 SALUTE konumu, 92720-92725 metin alanları, 92730 gelen kutusu, 92731 ayrıntı,
         92732 DOĞRULA, 92733 GÖNDER, 92734 durum, 92740-92745 etiketler.

    Parametreler:
        0: pencere <DISPLAY>   1: sol   2: üst   3: genişlik   4: yükseklik   (içerik alanı)

    Dönüş: yok
*/

params ["_display", "_left", "_top", "_width", "_height"];

private _rowH = (((_height - 0.01) / 11) min 0.04);
private _dark = [0.1, 0.45, 0.15, 1];
private _green = [0.25, 1, 0.35, 1];

private _leftW = _width * 0.5;
private _rightX = _left + _leftW + 0.02;
private _rightW = _width - _leftW - 0.02;
private _labelW = 0.15;

private _button = {
    params ["_display", "_idc", "_text", "_px", "_py", "_pw", "_ph", "_color"];
    private _control = [_display, _idc, "RscButtonMenu", _px, _py, _pw, _ph] call TC2_fnc_uiMakeControl;
    _control ctrlSetText _text;
    _control ctrlSetTextColor [0.25, 1, 0.35, 1];
    _control ctrlSetBackgroundColor _color;
    _control
};

private _combo = {
    params ["_display", "_idc", "_px", "_py", "_pw", "_ph", "_items"];
    private _control = [_display, _idc, "RscCombo", _px, _py, _pw, _ph] call TC2_fnc_uiMakeControl;
    _control ctrlSetBackgroundColor [0, 0.08, 0.02, 1];
    _control ctrlSetTextColor [0.25, 1, 0.35, 1];
    {
        private _index = _control lbAdd (_x select 0);
        _control lbSetData [_index, _x select 1];
    } forEach _items;
    _control lbSetCurSel 0;
    _control
};

// Tür seçimi
private _type = [_display, 92700, _left, _top, _leftW, _rowH - 0.004, [
    ["SALUTE - düşman gözlem raporu", "SALUTE"],
    ["SITREP - durum raporu", "SITREP"],
    ["LACE - birlik durumu (Liquid, Ammo, Casualties, Equipment)", "LACE"]
]] call _combo;
_type ctrlAddEventHandler ["LBSelChanged", {call TC2_fnc_rptUiChanged}];

// Form satırları: etiket + metin alanı (satır 1-6). Etiketler türe göre rptUiChanged'de değişir.
private _rows = [];
for "_k" from 0 to 5 do {
    _rows pushBack [0, _k + 1, "", 92740 + _k, [[92720 + _k, "edit", 1]]];
};
[_display, _left, _top, _leftW, 0, _labelW, _rowH, _rows] call TC2_fnc_uiBuildRows;

// Konumlar (LACE'te metin alanı daralır, durum listesi yanına gelir)
private _editX = _left + _labelW;
private _editW = _leftW - _labelW - 0.004;
private _positions = [];
for "_k" from 0 to 5 do {
    _positions pushBack [_editX, _top + (_k + 1) * _rowH, _editW, _rowH - 0.004];
};
missionNamespace setVariable ["TC2_rpt_pos", _positions];

private _statusItems = [
    ["— durum seçin —", ""],
    ["YEŞİL - tam operasyonel (85 yüzde +)", "GREEN"],
    ["AMBER - büyük ölçüde (70-84)", "AMBER"],
    ["KIRMIZI - sınırlı (50-69)", "RED"],
    ["SİYAH - operasyonel değil (50 altı)", "BLACK"],
    ["BİLİNMİYOR", "UNKNOWN"]
];
for "_k" from 0 to 3 do {
    [_display, 92710 + _k, _editX, _top + (_k + 1) * _rowH, 0.2, _rowH - 0.004, _statusItems] call _combo;
};

// SALUTE konumu: kendi konumum ya da görebildiğim bir işaret (rptUiUpdate doldurur)
[_display, 92716, _editX, _top + 3 * _rowH, _editW, _rowH - 0.004, [["Kendi konumum", "OWN"]]] call _combo;

private _send = [_display, 92733, "RAPORU GÖNDER", _left, _top + 8 * _rowH, _leftW, _rowH - 0.004, _dark] call _button;
_send ctrlAddEventHandler ["ButtonClick", {call TC2_fnc_rptUiSend}];

// Sağ: gelen raporlar
[_display, 92730, _rightX, _top, _rightW, _rowH - 0.004, [["— gelen raporlar —", ""]]] call _combo;
(_display displayCtrl 92730) ctrlAddEventHandler ["LBSelChanged", {call TC2_fnc_rptUiUpdate}];

private _details = [_display, 92731, "RscStructuredText", _rightX, _top + _rowH, _rightW, _rowH * 7.2] call TC2_fnc_uiMakeControl;
_details ctrlSetBackgroundColor [0, 0.05, 0.01, 1];

private _verify = [_display, 92732, "SALUTE'U DOĞRULA (S2 / CO)", _rightX, _top + 8.4 * _rowH, _rightW, _rowH - 0.004, _dark] call _button;
_verify ctrlAddEventHandler ["ButtonClick", {call TC2_fnc_rptUiVerify}];

private _status = [_display, 92734, "RscText", _left, _top + 10 * _rowH + 0.006, _width, _rowH] call TC2_fnc_uiMakeControl;
_status ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
_status ctrlSetTextColor _green;
_status ctrlSetFontHeight (_rowH * 0.45);

missionNamespace setVariable ["TC2_rpt_type", "SALUTE"];
missionNamespace setVariable ["TC2_rpt_data", ["EMPTY", 1, false, false, []]];
missionNamespace setVariable ["TC2_rpt_statusText", ""];
missionNamespace setVariable ["TC2_rpt_sig", ""];
missionNamespace setVariable ["TC2_rpt_detailText", ""];
