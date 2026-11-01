/*
    Fonksiyon: TC2_fnc_casUiUpdate
    Çalışma yeri: İstemci

    CAS sekmesini günceller: alıcı ve hedef listeleri (yalnızca içerik değiştiyse yeniden doldurulur, seçim korunur),
    mesafe birimi, durum satırı, geri okuma sonucu. Pencere kapalıysa bir şey yapmaz.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};
if (isNull (_display displayCtrl 92200)) exitWith {};

(missionNamespace getVariable ["TC2_cas_data", [false, [], []]]) params ["_isJtac", "_targets", "_summary"];
private _markers = (missionNamespace getVariable ["TC2_cop_data", [[], []]]) select 1;

// Listeler yalnızca içerik değişince yeniden doldurulur.
private _signature = str [_targets apply {_x select 0}, _markers apply {_x select 0}];
if !(_signature isEqualTo (missionNamespace getVariable ["TC2_cas_sig", ""])) then {
    missionNamespace setVariable ["TC2_cas_sig", _signature];

    private _refill = {
        params ["_control", "_items", "_placeholder"];
        private _previous = _control lbData (lbCurSel _control);
        lbClear _control;
        private _first = _control lbAdd (_placeholder select 0);
        _control lbSetData [_first, _placeholder select 1];
        private _restore = 0;
        {
            private _index = _control lbAdd (_x select 0);
            _control lbSetData [_index, _x select 1];
            if ((_x select 1) isEqualTo _previous) then {_restore = _index};
        } forEach _items;
        _control lbSetCurSel _restore;
    };

    [
        _display displayCtrl 92200,
        _targets apply {[format ["%1   [%2]  %3 m", _x select 1, _x select 2, _x select 3], _x select 0]},
        ["— ağda hava aracı yok —", ""]
    ] call _refill;

    [
        _display displayCtrl 92209,
        _markers apply {[format ["#%1  %2  grid %3", _x select 0, [_x select 1] call TC2_fnc_copTypeName, [_x select 2] call TC2_fnc_casGrid], str (_x select 0)]},
        ["— işaret seçin (HARİTA sekmesi) —", "-1"]
    ] call _refill;

    call TC2_fnc_casUiChanged;
};

// Durum satırı
private _statusText = missionNamespace getVariable ["TC2_cas_statusText", ""];
private _color = [0.25, 1, 0.35, 1];

if (!_isJtac) then {
    _statusText = "JTAC YETKİSİ GEREKLİ: yalnızca JTAC/FAC(A) 9-Line gönderebilir.";
    _color = [1, 0.8, 0.2, 1];
} else {
    if (_statusText isEqualTo "" && {count _summary > 0}) then {
        _statusText = switch (_summary select 1) do {
            case "SENT":          {format ["TALEP #%1  |  %2  |  geri okuma bekleniyor", _summary select 0, _summary select 2]};
            case "READBACK_OK":   {format ["TALEP #%1  |  GERİ OKUMA DOĞRU", _summary select 0]};
            case "READBACK_FAIL": {format ["TALEP #%1  |  GERİ OKUMA YANLIŞ", _summary select 0]};
            case "ABORTED":       {format ["TALEP #%1  |  İPTAL EDİLDİ", _summary select 0]};
            default {""};
        };
    };
    if (_statusText find "GEÇERSİZ" >= 0 || {_statusText find "YOK" >= 0} || {_statusText find "yetkiniz" >= 0} || {_statusText find "bulunamadı" >= 0}) then {_color = [1, 0.4, 0.4, 1]};
};

private _statusControl = _display displayCtrl 92223;
_statusControl ctrlSetText ("  " + _statusText);
_statusControl ctrlSetTextColor _color;

// Geri okuma sonucu
private _resultsText = "";
if (count _summary > 0) then {
    _resultsText = format ["<t size='0.9'>TALEP #%1  |  %2<br/>%3</t>", _summary select 0, _summary select 1, [_summary select 3] call TC2_fnc_casResultText];
};
(_display displayCtrl 92222) ctrlSetStructuredText parseText _resultsText;
