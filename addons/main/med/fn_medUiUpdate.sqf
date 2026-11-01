/*
    Fonksiyon: TC2_fnc_medUiUpdate
    Çalışma yeri: İstemci

    MEDEVAC sekmesini günceller: görünürlük (yalnızca MEDEVAC sekmesinde), form (yalnızca yazma yetkisi varsa), talepler listesi, seçili talebin
    9 satırı ve durumu (AÇIK / KABUL + ETA / İPTAL), İPTAL düğmesi (yalnızca kendi talebi), alım yeri listesi, durum satırı.
    Yetkisiz (Level 1 ya da izleme) durumda form ve liste GİZLİ, yalnızca açıklama görünür.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display || {isNull (_display displayCtrl 92800)}) exitWith {};

(missionNamespace getVariable ["TC2_med_data", ["EMPTY", 1, false, []]]) params ["_code", "_level", "_canWrite", "_requests"];

private _onTab = (missionNamespace getVariable ["TC2_ui_tab", 0]) == 7;
private _ok = _code isEqualTo "OK";

private _formIds = [92803, 92810, 92811, 92812, 92813, 92814, 92815, 92816, 92817, 92818, 92819, 92820, 92821, 92822, 92823, 92830, 92831, 92832, 92833, 92834, 92835, 92836, 92837, 92838];
{(_display displayCtrl _x) ctrlShow (_onTab && _canWrite)} forEach _formIds;
{(_display displayCtrl _x) ctrlShow (_onTab && _canWrite)} forEach [92800, 92802];
(_display displayCtrl 92801) ctrlShow _onTab;
(_display displayCtrl 92804) ctrlShow _onTab;

if (!_onTab) exitWith {};

// alım yeri listesi
if (_canWrite) then {
    private _markers = (missionNamespace getVariable ["TC2_cop_data", [[], [], []]]) select 1;
    private _items = _markers apply {
        [format ["İşaret #%1  %2  %3", _x select 0, [_x select 1] call TC2_fnc_copTypeName, [_x select 2] call TC2_fnc_casGrid], format ["M%1", _x select 0]]
    };
    [_display displayCtrl 92810, _items, ["Kendi konumum", "OWN"]] call TC2_fnc_uiFillCombo;
};

// talepler listesi
private _inbox = _display displayCtrl 92800;
private _tag = {
    switch (_this) do {
        case "OPEN": {"AÇIK"};
        case "ACCEPTED": {"KABUL"};
        default {"İPTAL"};
    }
};
private _signature = str (_requests apply {[_x select 0, _x select 3, floor ((_x select 2) / 60)]});
if (_canWrite && {!(_signature isEqualTo (missionNamespace getVariable ["TC2_med_sig", ""]))}) then {
    missionNamespace setVariable ["TC2_med_sig", _signature];
    private _items = _requests apply {
        [format ["#%1 %2  [%3]  %4 dk", _x select 0, _x select 1, (_x select 3) call _tag, floor ((_x select 2) / 60)], str (_x select 0)]
    };
    [_inbox, _items, [format ["— talepler (%1) —", count _requests], ""]] call TC2_fnc_uiFillCombo;
};

private _selected = _inbox lbData (lbCurSel _inbox);
private _request = [];
{
    if (str (_x select 0) isEqualTo _selected) exitWith {_request = _x};
} forEach _requests;

private _detail = switch (true) do {
    case (!_ok): {format ["BAĞLANTI YOK | %1", [_code] call TC2_fnc_accessReasonText]};
    case (!_canWrite): {"MEDEVAC sekmesi Level 2 (Mavi kart) ve üstü içindir; izleme modunda talep görünmez."};
    case (_request isEqualTo []): {format ["%1 talep var. Listeden seçin ya da soldaki formla yeni talep verin.<br/>Alıcı: ağınızdaki helikopter mürettebatı.", count _requests]};
    default {
        _request params ["_id", "_callsign", "_age", "_status", "_acceptor", "_eta", "_mine", "_lines"];
        private _head = format [
            "<t color='#40ff59'>#%1  %2</t>   %3 dk önce   <t color='%4'>%5</t>",
            _id, _callsign, floor (_age / 60),
            switch (_status) do {case "OPEN": {"#ffcc33"}; case "ACCEPTED": {"#40ff59"}; default {"#aaaaaa"}},
            switch (_status) do {
                case "OPEN": {"KABUL BEKLİYOR"};
                case "ACCEPTED": {format ["KABUL: %1  ETA %2 dk", _acceptor, _eta]};
                default {"İPTAL"};
            }
        ];
        private _text = _head;
        {
            _text = _text + format ["<br/><t color='#1f9930'>%1</t>  %2", _x select 0, _x select 1];
        } forEach _lines;
        _text
    };
};
if !(_detail isEqualTo (missionNamespace getVariable ["TC2_med_detailText", ""])) then {
    missionNamespace setVariable ["TC2_med_detailText", _detail];
    (_display displayCtrl 92801) ctrlSetStructuredText parseText format ["<t size='0.8'>%1</t>", _detail];
};

(_display displayCtrl 92802) ctrlEnable (!(_request isEqualTo []) && {_request select 6} && {(_request select 3) in ["OPEN", "ACCEPTED"]});

private _status = missionNamespace getVariable ["TC2_med_statusText", ""];
if (_status isEqualTo "") then {
    _status = if (_ok) then {format ["Level %1 | %2", _level, ["izleme", "talep verebilirsiniz"] select _canWrite]} else {"BAĞLANTI YOK"};
};
(_display displayCtrl 92804) ctrlSetText ("  " + _status);
