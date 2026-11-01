/*
    Fonksiyon: TC2_fnc_artyUiUpdate
    Çalışma yeri: İstemci

    TOPÇU (sekme 3) ve FDC (sekme 4) ekranlarını günceller:
      - görünürlük: TOPÇU sekmesinde etkin görev yoksa (ya da YENİ GÖREV seçildiyse) PANEL A (CFF formu), etkin görev varsa PANEL B (denetim);
        FDC sekmesinde FDC yetkisi yoksa yalnızca durum satırı,
      - açılır listeler (FDC, işaret/hedef, kuyruk, batarya): yalnızca içerik değişince yeniden doldurulur, seçim korunur,
      - özet, günlük, CFF ayrıntısı, batarya bilgisi, düğmelerin etkinliği, durum satırı.
    Metinler yalnızca değişince yazılır (uiWatch ve olaylar sık çağırabilir).

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};
if (isNull (_display displayCtrl 92400) || {isNull (_display displayCtrl 92450)}) exitWith {};

(missionNamespace getVariable ["TC2_arty_data", [false, false, [], [], [], [], []]]) params ["_isObs", "_isFdc", "_fdcTargets", "_mine", "_queue", "_batteries", "_targets"];

private _tab = missionNamespace getVariable ["TC2_ui_tab", 0];
private _finished = ["EOM", "REJECTED", "CANCELLED"];

private _stateName = {
    switch (_this) do {
        case "REQUEST":      {"FDC BEKLİYOR"};
        case "READY":        {"HAZIR (FIRE bekleniyor)"};
        case "FIRING":       {"ATEŞ"};
        case "SPOTTING":     {"GÖZLEM (düzeltme bekleniyor)"};
        case "SURVEILLANCE": {"GÖZETİM (EOM bekleniyor)"};
        case "EOM":          {"BİTTİ"};
        case "REJECTED":     {"REDDEDİLDİ"};
        case "CANCELLED":    {"İPTAL"};
        default {_this};
    }
};

// --- panel kararı
private _active = !(_mine isEqualTo []) && {!((_mine select 1) in _finished)};
if (!_active) then {missionNamespace setVariable ["TC2_arty_forceNew", false]};
private _panelA = !_active || {missionNamespace getVariable ["TC2_arty_forceNew", false]};
missionNamespace setVariable ["TC2_arty_panelA", _panelA];

// --- görünürlük
{(_display displayCtrl _x) ctrlShow (_tab == 3 && _isObs && _panelA)} forEach (missionNamespace getVariable ["TC2_arty_idsA", []]);
{(_display displayCtrl _x) ctrlShow (_tab == 3 && _isObs && !_panelA)} forEach (missionNamespace getVariable ["TC2_arty_idsB", []]);
{(_display displayCtrl _x) ctrlShow (_tab == 4 && _isFdc)} forEach (missionNamespace getVariable ["TC2_arty_idsF", []]);
(_display displayCtrl 92420) ctrlShow (_tab == 3);
(_display displayCtrl 92462) ctrlShow (_tab == 4);

if (_tab == 3) then {call TC2_fnc_artyUiChanged};

// --- listeler
private _markers = (missionNamespace getVariable ["TC2_cop_data", [[], []]]) select 1;
private _signature = str [
    _fdcTargets apply {_x select 0}, _markers apply {_x select 0}, _targets apply {_x select 0},
    _queue apply {[_x select 0, _x select 1]}, _batteries apply {_x select 0}
];

if !(_signature isEqualTo (missionNamespace getVariable ["TC2_arty_sig", ""])) then {
    missionNamespace setVariable ["TC2_arty_sig", _signature];

    [_display displayCtrl 92400, _fdcTargets apply {[_x select 1, _x select 0]}, ["— ağda FDC yok —", ""]] call TC2_fnc_uiFillCombo;

    private _references = (_markers apply {[format ["#%1  %2  grid %3", _x select 0, [_x select 1] call TC2_fnc_copTypeName, [_x select 2] call TC2_fnc_casGrid], format ["M%1", _x select 0]]})
        + (_targets apply {[format ["HEDEF %1  grid %2", _x select 0, _x select 1], format ["T%1", _x select 0]]});
    [_display displayCtrl 92408, _references, ["— işaret / hedef seçin —", ""]] call TC2_fnc_uiFillCombo;

    [_display displayCtrl 92450, _queue apply {[format ["#%1  %2  %3", _x select 0, _x select 2, (_x select 1) call _stateName], str (_x select 0)]}, ["— kuyruk —", "0"]] call TC2_fnc_uiFillCombo;

    [_display displayCtrl 92452, _batteries apply {[format ["%1  [%2]  %3 top%4", _x select 1, _x select 2, _x select 3, ["  (OYUNCU YOK)", ""] select (_x select 4)], _x select 0]}, ["— batarya seçin —", ""]] call TC2_fnc_uiFillCombo;
};

// --- TOPÇU (gözlemci) metinleri
private _statusText = missionNamespace getVariable ["TC2_arty_statusText", ""];
private _code = missionNamespace getVariable ["TC2_arty_code", "OK"];
private _good = [0.25, 1, 0.35, 1];
private _bad = [1, 0.4, 0.4, 1];

if (_tab == 3) then {
    private _text = _statusText;
    private _color = _good;

    if (!_isObs) then {
        _text = "GÖZLEMCİ YETKİSİ GEREKLİ (FO / JFO ya da JTAC).";
        _color = [1, 0.8, 0.2, 1];
    } else {
        if !(_code isEqualTo "OK") then {
            _text = format ["BAĞLANTI YOK | %1", [_code] call TC2_fnc_accessReasonText];
            _color = _bad;
        } else {
            if (_text isEqualTo "" && {!(_mine isEqualTo [])}) then {
                _text = format ["#%1 | %2 | hedef %3", _mine select 0, (_mine select 1) call _stateName, ["-", _mine select 3] select !((_mine select 3) isEqualTo "")];
            };
            if ((_text find "GEÇERSİZ") >= 0 || {(_text find "DANGER") >= 0} || {(_text find "yetkiniz") >= 0} || {(_text find "ağda") >= 0}) then {_color = _bad};
        };
    };

    private _statusControl = _display displayCtrl 92420;
    _statusControl ctrlSetText ("  " + _text);
    _statusControl ctrlSetTextColor _color;

    if (_isObs && {!(_mine isEqualTo [])}) then {
        _mine params ["_id", "_state", "_observer", "_targetNo", "_grid", "_log", "", "_battery", "_phase", "", "", "_dangerClose", "_direction", "_fdcName"];

        private _info = format [
            "<t size='0.75'><t color='#40ff59'>#%1  %2</t><br/>HEDEF %3   GRID %4<br/>FDC %5   BATARYA %6<br/>FAZ %7%8   YÖN %9 mil</t>",
            _id, _state call _stateName, ["-", _targetNo] select !(_targetNo isEqualTo ""), _grid, _fdcName,
            ["-", _battery] select !(_battery isEqualTo ""), _phase, ["", "   DANGER CLOSE"] select _dangerClose, _direction
        ];
        if !(_info isEqualTo (missionNamespace getVariable ["TC2_arty_infoText", ""])) then {
            missionNamespace setVariable ["TC2_arty_infoText", _info];
            (_display displayCtrl 92444) ctrlSetStructuredText parseText _info;
        };

        private _logText = format ["<t size='0.7'>%1</t>", _log joinString "<br/>"];
        if !(_logText isEqualTo (missionNamespace getVariable ["TC2_arty_logText", ""])) then {
            missionNamespace setVariable ["TC2_arty_logText", _logText];
            (_display displayCtrl 92445) ctrlSetStructuredText parseText _logText;
        };

        (_display displayCtrl 92436) ctrlEnable (_state in ["SPOTTING", "SURVEILLANCE"]);
        (_display displayCtrl 92437) ctrlEnable (_state in ["SPOTTING", "SURVEILLANCE"]);
        (_display displayCtrl 92438) ctrlEnable (_state isEqualTo "READY");
        (_display displayCtrl 92439) ctrlEnable (_state in ["FIRING", "READY"]);
        (_display displayCtrl 92442) ctrlEnable !(_state in _finished);
    };
};

// --- FDC metinleri
if (_tab == 4) then {
    private _queueControl = _display displayCtrl 92450;
    private _selectedId = parseNumber (_queueControl lbData (lbCurSel _queueControl));
    private _selected = [];
    {
        if ((_x select 0) == _selectedId) exitWith {_selected = _x};
    } forEach _queue;

    private _text = _statusText;
    private _color = _good;

    if (!_isFdc) then {
        _text = "FDC YETKİSİ GEREKLİ.";
        _color = [1, 0.8, 0.2, 1];
    } else {
        if !(_code isEqualTo "OK") then {
            _text = format ["BAĞLANTI YOK | %1", [_code] call TC2_fnc_accessReasonText];
            _color = _bad;
        } else {
            if (_text isEqualTo "") then {_text = format ["Kuyruk: %1 görev", count (_queue select {!((_x select 1) in _finished)})]};
            if ((_text find "Menzil") >= 0 || {(_text find "menzili") >= 0} || {(_text find "KAPALI") >= 0} || {(_text find "yok") >= 0} || {(_text find "seçin") >= 0}) then {_color = _bad};
        };
    };

    private _statusControl = _display displayCtrl 92462;
    _statusControl ctrlSetText ("  " + _text);
    _statusControl ctrlSetTextColor _color;

    if (_isFdc) then {
        private _detailText = "";
        private _logText = "";
        if !(_selected isEqualTo []) then {
            _selected params ["_id", "_state", "_observer", "_targetNo", "_grid", "_log", "_lines", "_battery", "_phase", "_volume", "_manual", "_dangerClose", "_direction"];
            _detailText = format ["<t size='0.7'><t color='#40ff59'>#%1  %2  (%3)</t><br/>", _id, _state call _stateName, _observer];
            {
                _detailText = _detailText + format ["<t color='#1f9930'>%1</t>  %2<br/>", _x select 0, _x select 1];
            } forEach _lines;
            _detailText = _detailText + format ["YÖN %1 mil   HACİM %2%3%4</t>", _direction, _volume, ["", "   DANGER CLOSE"] select _dangerClose, ["", "   OYUNCU BATARYASI"] select _manual];
            _logText = format ["<t size='0.7'>%1</t>", _log joinString "<br/>"];

            (_display displayCtrl 92455) ctrlEnable (_state isEqualTo "REQUEST");
            (_display displayCtrl 92456) ctrlEnable (_state in ["REQUEST", "READY"]);
            (_display displayCtrl 92458) ctrlEnable (_state isEqualTo "FIRING" && {_manual});
            (_display displayCtrl 92459) ctrlEnable (_state isEqualTo "FIRING" && {_manual});
            (_display displayCtrl 92460) ctrlEnable (_state isEqualTo "FIRING" && {_manual});
            (_display displayCtrl 92461) ctrlEnable (_state in ["FIRING", "READY"]);
        };

        if !(_detailText isEqualTo (missionNamespace getVariable ["TC2_arty_detailText", ""])) then {
            missionNamespace setVariable ["TC2_arty_detailText", _detailText];
            (_display displayCtrl 92451) ctrlSetStructuredText parseText _detailText;
        };
        if !(_logText isEqualTo (missionNamespace getVariable ["TC2_arty_fdcLogText", ""])) then {
            missionNamespace setVariable ["TC2_arty_fdcLogText", _logText];
            (_display displayCtrl 92463) ctrlSetStructuredText parseText _logText;
        };

        private _batteryControl = _display displayCtrl 92452;
        private _batteryKey = _batteryControl lbData (lbCurSel _batteryControl);
        private _batteryText = "<t size='0.75'>Batarya seçilmedi.</t>";
        {
            if ((_x select 0) isEqualTo _batteryKey) exitWith {
                _batteryText = format ["<t size='0.75'>%1<br/>MÜRETTEBAT %2   TOP %3<br/>KULLANIM %4</t>", _x select 1, _x select 2, _x select 3, ["KULLANILAMAZ (oyuncu yok)", "uygun"] select (_x select 4)];
            };
        } forEach _batteries;
        if !(_batteryText isEqualTo (missionNamespace getVariable ["TC2_arty_batteryText", ""])) then {
            missionNamespace setVariable ["TC2_arty_batteryText", _batteryText];
            (_display displayCtrl 92464) ctrlSetStructuredText parseText _batteryText;
        };
    };
};
