/*
    Fonksiyon: TC2_fnc_opordBuild
    Çalışma yeri: İstemci (uiOpen çağırır, pencere kurulurken)

    OPORD sekmesinin kontrollerini kurar (varsayılan GİZLİ; opordUiUpdate gösterir).
      Üst:   bölüm seçimi (görünür bölümler + "GİZLİ - Level N" başlıkları) ve OKUDUM / ANLADIM (onay) düğmesi
      Orta:  belge üst bilgisi (başlık, DTG, gizlilik etiketi, sürüm, seviyeniz, onay sayısı) ve bölüm metni (kaydırılabilir okuma alanı)
      Alt:   Level 3 için DÜZENLE / OKU geçişi, bölüm seviyesi, KAYDET, ŞABLON; durum satırı
    IDC: 92600 bölüm listesi, 92601 OKUDUM, 92602 üst bilgi, 92603 okuma alanı, 92604 düzenleme alanı, 92605 seviye, 92606 KAYDET,
         92607 DÜZENLE/OKU, 92608 ŞABLON, 92609 durum, 92610 belge türü (OPORD / WARNO).

    Parametreler:
        0: pencere <DISPLAY>   1: sol   2: üst   3: genişlik   4: yükseklik   (içerik alanı)

    Dönüş: yok
*/

params ["_display", "_left", "_top", "_width", "_height"];

private _rowH = (((_height - 0.01) / 11) min 0.04);
private _dark = [0.1, 0.45, 0.15, 1];
private _green = [0.25, 1, 0.35, 1];

private _docType = [_display, 92610, "RscCombo", _left, _top, 0.2, _rowH - 0.004] call TC2_fnc_uiMakeControl;
_docType ctrlSetBackgroundColor [0, 0.08, 0.02, 1];
_docType ctrlSetTextColor [0.25, 1, 0.35, 1];
{
    private _index = _docType lbAdd (_x select 0);
    _docType lbSetData [_index, _x select 1];
} forEach [["OPORD (Operasyon Emri)", "OPORD"], ["WARNO (Uyarı Emri)", "WARNO"]];
_docType lbSetCurSel 0;
_docType ctrlAddEventHandler ["LBSelChanged", {
    params ["_control", "_index"];
    missionNamespace setVariable ["TC2_opord_doc", _control lbData _index];
    missionNamespace setVariable ["TC2_opord_data", ["EMPTY", 1, [], [], [], 0, false]];
    missionNamespace setVariable ["TC2_opord_sig", ""];
    missionNamespace setVariable ["TC2_opord_loadedKey", ""];
    missionNamespace setVariable ["TC2_opord_viewText", "\n"];
    missionNamespace setVariable ["TC2_opord_infoText", ""];
    call TC2_fnc_opordUiRequest;
    call TC2_fnc_opordUiUpdate;
}];

private _section = [_display, 92600, "RscCombo", _left + 0.21, _top, _width - 0.42, _rowH] call TC2_fnc_uiMakeControl;
_section ctrlSetBackgroundColor [0, 0.08, 0.02, 1];
_section ctrlSetTextColor _green;
_section ctrlAddEventHandler ["LBSelChanged", {call TC2_fnc_opordUiUpdate}];

private _button = {
    params ["_display", "_idc", "_text", "_px", "_py", "_pw", "_ph", "_color"];
    private _control = [_display, _idc, "RscButtonMenu", _px, _py, _pw, _ph] call TC2_fnc_uiMakeControl;
    _control ctrlSetText _text;
    _control ctrlSetTextColor [0.25, 1, 0.35, 1];
    _control ctrlSetBackgroundColor _color;
    _control
};

private _ack = [_display, 92601, "OKUDUM / ANLADIM", _left + _width - 0.2, _top, 0.2, _rowH - 0.004, _dark] call _button;
_ack ctrlAddEventHandler ["ButtonClick", {["ACK"] call TC2_fnc_opordUiAction}];

private _info = [_display, 92602, "RscStructuredText", _left, _top + _rowH + 0.004, _width, _rowH * 1.6] call TC2_fnc_uiMakeControl;
_info ctrlSetBackgroundColor [0, 0.05, 0.01, 1];

private _textTop = _top + _rowH * 2.7;
private _textHeight = _rowH * 6.6;

private _view = [_display, 92603, "TC2_RscMultiView", _left, _textTop, _width, _textHeight] call TC2_fnc_uiMakeControl;
_view ctrlSetFontHeight 0.032;

private _editor = [_display, 92604, "TC2_RscMultiEdit", _left, _textTop, _width, _textHeight] call TC2_fnc_uiMakeControl;
_editor ctrlSetFontHeight 0.032;

private _editRowY = _top + 9.45 * _rowH;
private _toggle = [_display, 92607, "DÜZENLE", _left, _editRowY, 0.18, _rowH - 0.004, _dark] call _button;
_toggle ctrlAddEventHandler ["ButtonClick", {["TOGGLE"] call TC2_fnc_opordUiAction}];

private _level = [_display, 92605, "RscCombo", _left + 0.19, _editRowY, 0.3, _rowH - 0.004] call TC2_fnc_uiMakeControl;
_level ctrlSetBackgroundColor [0, 0.08, 0.02, 1];
_level ctrlSetTextColor _green;
{
    private _index = _level lbAdd (_x select 0);
    _level lbSetData [_index, _x select 1];
} forEach [["BÖLÜM SEVİYESİ: Level 1 (herkes)", "1"], ["BÖLÜM SEVİYESİ: Level 2", "2"], ["BÖLÜM SEVİYESİ: Level 3 (komuta)", "3"]];
_level lbSetCurSel 0;

private _save = [_display, 92606, "KAYDET", _left + 0.5, _editRowY, 0.16, _rowH - 0.004, _dark] call _button;
_save ctrlAddEventHandler ["ButtonClick", {["SAVE"] call TC2_fnc_opordUiAction}];

private _template = [_display, 92608, "ŞABLON OLUŞTUR", _left + 0.67, _editRowY, 0.22, _rowH - 0.004, [0.02, 0.1, 0.03, 1]] call _button;
_template ctrlAddEventHandler ["ButtonClick", {["TEMPLATE"] call TC2_fnc_opordUiAction}];

private _status = [_display, 92609, "RscText", _left, _top + 10 * _rowH + 0.006, _width, _rowH] call TC2_fnc_uiMakeControl;
_status ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
_status ctrlSetTextColor _green;
_status ctrlSetFontHeight (_rowH * 0.45);

missionNamespace setVariable ["TC2_opord_ids", [92600, 92601, 92602, 92609, 92610]];
missionNamespace setVariable ["TC2_opord_doc", "OPORD"];
missionNamespace setVariable ["TC2_opord_idsEdit", [92605, 92606, 92607]];
missionNamespace setVariable ["TC2_opord_edit", false];
missionNamespace setVariable ["TC2_opord_loadedKey", ""];
missionNamespace setVariable ["TC2_opord_sig", ""];
missionNamespace setVariable ["TC2_opord_statusText", ""];
