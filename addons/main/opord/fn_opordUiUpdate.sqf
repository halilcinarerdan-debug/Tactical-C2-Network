/*
    Fonksiyon: TC2_fnc_opordUiUpdate
    Çalışma yeri: İstemci

    OPORD sekmesini günceller: görünürlük (yalnızca OPORD sekmesinde), bölüm listesi (içerik değişince; seçim korunur), üst bilgi,
    bölüm metni (kaydırılabilir), Level 3 için düzenleme araçları, onay düğmesi, durum satırı.
    Gizli bölümlerin yalnızca başlığı ve gereken seviye gösterilir; METİN istemciye hiç gelmediği için gösterilemez.
    Düzenleme alanı, yazarken ezilmesin diye yalnızca bölüm değişince/düzenleme açılınca doldurulur.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display || {isNull (_display displayCtrl 92600)}) exitWith {};

(missionNamespace getVariable ["TC2_opord_data", ["EMPTY", 1, [], [], [], 0, false]]) params ["_code", "_level", "_header", "_visible", "_hidden", "_ackCount", "_mine"];

private _tab = missionNamespace getVariable ["TC2_ui_tab", 0];
private _onTab = _tab == 5;
private _isEditor = _level >= 3 && {_code isEqualTo "OK"};
private _editing = _isEditor && {missionNamespace getVariable ["TC2_opord_edit", false]};
private _hasDocument = _code isEqualTo "OK";

{(_display displayCtrl _x) ctrlShow _onTab} forEach (missionNamespace getVariable ["TC2_opord_ids", []]);
{(_display displayCtrl _x) ctrlShow (_onTab && _isEditor)} forEach (missionNamespace getVariable ["TC2_opord_idsEdit", []]);
(_display displayCtrl 92603) ctrlShow (_onTab && !_editing);
(_display displayCtrl 92604) ctrlShow (_onTab && _editing);
(_display displayCtrl 92608) ctrlShow (_onTab && _isEditor && !_hasDocument);
(_display displayCtrl 92601) ctrlEnable (_hasDocument && !_mine);
(_display displayCtrl 92601) ctrlSetText (["OKUDUM / ANLADIM", "ONAYLANDI"] select _mine);
(_display displayCtrl 92607) ctrlSetText (["DÜZENLE", "OKUMA MODU"] select _editing);

if (!_onTab) exitWith {};

// bölüm listesi
private _signature = str [_visible apply {[_x select 0, _x select 2]}, _hidden apply {_x select 0}];
if !(_signature isEqualTo (missionNamespace getVariable ["TC2_opord_sig", ""])) then {
    missionNamespace setVariable ["TC2_opord_sig", _signature];
    private _items = (_visible apply {[_x select 1, _x select 0]}) + (_hidden apply {[format ["[GİZLİ - Level %1]  %2", _x select 2, _x select 1], "#" + (_x select 0)]});
    [_display displayCtrl 92600, _items, ["— bölüm seçin —", ""]] call TC2_fnc_uiFillCombo;
};

// seçili bölüm
private _combo = _display displayCtrl 92600;
private _selected = _combo lbData (lbCurSel _combo);
private _section = [];
{
    if ((_x select 0) isEqualTo _selected) exitWith {_section = _x};
} forEach _visible;

private _body = switch (true) do {
    case (!_hasDocument): {
        switch (_code) do {
            case "EMPTY": {"Henüz yayımlanmış OPORD yok." + (["", " Level 3 iseniz ŞABLON OLUŞTUR ile başlayabilirsiniz."] select _isEditor)};
            default {format ["BAĞLANTI YOK | %1", [_code] call TC2_fnc_accessReasonText]};
        }
    };
    case (_selected isEqualTo ""): {"Soldaki listeden bir bölüm seçin."};
    case ((_selected select [0, 1]) isEqualTo "#"): {format ["Bu bölümü görme yetkiniz yok.%1Gereken: Level %2   Sizin seviyeniz: Level %3", toString [10, 10], ((_hidden select {("#" + (_x select 0)) isEqualTo _selected}) param [0, ["", "", "?"]]) select 2, _level]};
    default {_section param [3, ""]};
};

if !(_body isEqualTo (missionNamespace getVariable ["TC2_opord_viewText", "\n"])) then {
    missionNamespace setVariable ["TC2_opord_viewText", _body];
    (_display displayCtrl 92603) ctrlSetText _body;
};

// düzenleme alanı: bölüm değişince / düzenleme açılınca doldur
if (_editing && {!(_selected isEqualTo (missionNamespace getVariable ["TC2_opord_loadedKey", ""]))}) then {
    missionNamespace setVariable ["TC2_opord_loadedKey", _selected];
    (_display displayCtrl 92604) ctrlSetText (_section param [3, ""]);
    (_display displayCtrl 92605) lbSetCurSel (((_section param [2, 1]) - 1) max 0);
};

// üst bilgi
private _infoText = "<t size='0.8'>Belge yok.</t>";
if (_hasDocument) then {
    _header params ["_title", "_dtg", "_classification", "_version", "_issuer"];
    _infoText = format [
        "<t size='0.75'><t color='#40ff59'>%1</t>   %2   <t color='#ffcc33'>%3</t><br/>SÜRÜM %4   YAYIMLAYAN %5   |   YETKİNİZ: <t color='#40ff59'>Level %6</t>%7</t>",
        _title, _dtg, _classification, _version, _issuer, _level,
        ["", format ["   |   ONAY: %1", _ackCount]] select _isEditor
    ];
};
if !(_infoText isEqualTo (missionNamespace getVariable ["TC2_opord_infoText", ""])) then {
    missionNamespace setVariable ["TC2_opord_infoText", _infoText];
    (_display displayCtrl 92602) ctrlSetStructuredText parseText _infoText;
};

// durum satırı
private _status = missionNamespace getVariable ["TC2_opord_statusText", ""];
if (_status isEqualTo "") then {
    _status = if (_hasDocument) then {format ["Level %1 | %2 bölüm görünür, %3 bölüm gizli", _level, count _visible, count _hidden]} else {"OPORD yok"};
};
(_display displayCtrl 92609) ctrlSetText ("  " + _status);
