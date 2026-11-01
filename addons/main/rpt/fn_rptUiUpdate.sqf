/*
    Fonksiyon: TC2_fnc_rptUiUpdate
    Çalışma yeri: İstemci

    RAPOR sekmesini günceller: görünürlük (yalnızca RAPOR sekmesinde), form (yalnızca yazma yetkisi varsa), gelen kutusu (Level 2+),
    seçili raporun ayrıntısı, DOĞRULA düğmesi (yalnızca S2 / CO, doğrulanmamış SALUTE seçiliyken), SALUTE konum listesi, durum satırı.
    Yetkisiz (Level 1 ya da izleme) durumda form ve gelen kutusu GİZLİ, yalnızca açıklama görünür: bilgi güvenirliği.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display || {isNull (_display displayCtrl 92700)}) exitWith {};

(missionNamespace getVariable ["TC2_rpt_data", ["EMPTY", 1, false, false, []]]) params ["_code", "_level", "_canWrite", "_canVerify", "_reports"];

private _onTab = (missionNamespace getVariable ["TC2_ui_tab", 0]) == 6;
private _type = missionNamespace getVariable ["TC2_rpt_type", "SALUTE"];
private _ok = _code isEqualTo "OK";
private _reader = _ok && {_level >= 2};

// görünürlük
private _fieldIds = switch (_type) do {
    case "SALUTE": {[92740, 92741, 92742, 92743, 92744, 92745, 92720, 92721, 92723, 92724, 92725, 92716]};
    case "SITREP": {[92740, 92741, 92742, 92743, 92744, 92745, 92720, 92721, 92722, 92723, 92724, 92725]};
    default {[92740, 92741, 92742, 92743, 92710, 92711, 92712, 92713, 92720, 92721, 92722, 92723]};
};
private _all = [92700, 92710, 92711, 92712, 92713, 92716, 92720, 92721, 92722, 92723, 92724, 92725, 92730, 92731, 92732, 92733, 92734, 92740, 92741, 92742, 92743, 92744, 92745];
{
    private _show = _onTab && (switch (true) do {
        case (_x in [92700, 92733] || {_x in _fieldIds}): {_canWrite};
        case (_x in [92730]): {_reader};
        case (_x in [92731, 92734]): {true};
        case (_x == 92732): {_canVerify && _reader};
        default {false};
    });
    (_display displayCtrl _x) ctrlShow _show;
} forEach _all;

if (!_onTab) exitWith {};

// SALUTE konum listesi: kendi konum + görebildiğim işaretler
if (_canWrite && {_type isEqualTo "SALUTE"}) then {
    private _markers = (missionNamespace getVariable ["TC2_cop_data", [[], [], []]]) select 1;
    private _items = _markers apply {
        [format ["İşaret #%1  %2  %3", _x select 0, [_x select 1] call TC2_fnc_copTypeName, [_x select 2] call TC2_fnc_casGrid], format ["M%1", _x select 0]]
    };
    [_display displayCtrl 92716, _items, ["Kendi konumum", "OWN"]] call TC2_fnc_uiFillCombo;
};

// gelen kutusu
private _inbox = _display displayCtrl 92730;
private _signature = str (_reports apply {[_x select 0, _x select 4, floor ((_x select 3) / 60)]});
if (_reader && {!(_signature isEqualTo (missionNamespace getVariable ["TC2_rpt_sig", ""]))}) then {
    missionNamespace setVariable ["TC2_rpt_sig", _signature];
    private _items = _reports apply {
        [format ["#%1 %2  %3  %4 dk%5", _x select 0, _x select 1, _x select 2, floor ((_x select 3) / 60), ["", "  [DOĞRULANDI]"] select ((_x select 4) && {(_x select 1) isEqualTo "SALUTE"})], str (_x select 0)]
    };
    [_inbox, _items, [format ["— gelen raporlar (%1) —", count _reports], ""]] call TC2_fnc_uiFillCombo;
};

// seçili raporun ayrıntısı
private _selected = _inbox lbData (lbCurSel _inbox);
private _report = [];
{
    if (str (_x select 0) isEqualTo _selected) exitWith {_report = _x};
} forEach _reports;

private _detail = switch (true) do {
    case (!_ok): {format ["BAĞLANTI YOK | %1", [_code] call TC2_fnc_accessReasonText]};
    case (_level < 2): {"RAPOR sekmesi Level 2 (Mavi kart) ve üstü içindir.<br/>Level 1 yalnızca kendi görevlerini okur; raporları göremez."};
    case (_report isEqualTo []): {format ["%1 rapor var. Listeden seçin.<br/>Rapor yazmak için soldan türü seçip formu doldurun.", count _reports]};
    default {
        _report params ["_id", "_rType", "_callsign", "_age", "_verified", "_lines"];
        private _text = format [
            "<t color='#40ff59'>#%1  %2</t>   %3   %4 dk önce   <t color='%5'>%6</t>",
            _id, _rType, _callsign, floor (_age / 60),
            ["#ffcc33", "#40ff59"] select _verified,
            if (_rType isEqualTo "SALUTE") then {["DOĞRULANMAMIŞ", "S2 DOĞRULADI"] select _verified} else {"BEYAN"}
        ];
        {
            _text = _text + format ["<br/><t color='#1f9930'>%1</t>  %2", _x select 0, _x select 1];
        } forEach _lines;
        _text
    };
};
if !(_detail isEqualTo (missionNamespace getVariable ["TC2_rpt_detailText", ""])) then {
    missionNamespace setVariable ["TC2_rpt_detailText", _detail];
    (_display displayCtrl 92731) ctrlSetStructuredText parseText format ["<t size='0.8'>%1</t>", _detail];
};

(_display displayCtrl 92732) ctrlEnable (!(_report isEqualTo []) && {(_report select 1) isEqualTo "SALUTE"} && {!(_report select 4)});

// durum satırı
private _status = missionNamespace getVariable ["TC2_rpt_statusText", ""];
if (_status isEqualTo "") then {
    _status = if (_ok) then {
        format ["Level %1 | %2", _level, if (_canWrite) then {"rapor yazabilirsiniz"} else {"izleme"}]
    } else {
        "BAĞLANTI YOK"
    };
};
(_display displayCtrl 92734) ctrlSetText ("  " + _status);
