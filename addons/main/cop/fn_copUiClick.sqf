/*
    Fonksiyon: TC2_fnc_copUiClick
    Çalışma yeri: İSTEMCİ (terminal haritasının "MouseButtonClick" olayı)

    Haritaya tıklama. Mod (TC2_cop_mode):
      "PLACE"  -> tıklanan yere seçili türde (kategori + tür listesi) düşman işareti koy,
      "DELETE" -> tıklamaya en yakın işareti sil (tolerans: ekranın ~%2'si kadar mesafe),
      "MEASURE"-> iki noktaya sırayla tıkla: mesafe, yön (derece / mil), yükseklik farkı (A ve B çizilir; üçüncü tık yeniden başlatır),
      "INFO"   -> tıklamaya en yakın dost birimin LACE bilgisini panelde göster (salt okuma, sunucuya istek yok),
      ""       -> bir şey yapma (harita yalnızca kaydırılır/yakınlaştırılır).
    Karar sunucudadır; burada yalnızca istek gönderilir.

    Parametreler: olay [harita, düğme, x, y, shift, ctrl, alt]
    Dönüş: yok
*/

params ["_map", "_button", "_x", "_y"];

private _mode = missionNamespace getVariable ["TC2_cop_mode", ""];
if (_button != 0 || {_mode isEqualTo ""}) exitWith {};

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _terminal) exitWith {};

private _world = _map ctrlMapScreenToWorld [_x, _y];
private _state = call TC2_fnc_netGetRadioState;

if (_mode isEqualTo "MEASURE") exitWith {
    private _points = missionNamespace getVariable ["TC2_cop_measure", []];
    if (count _points >= 2) then {_points = []};
    _world set [2, 0];
    _points pushBack _world;
    missionNamespace setVariable ["TC2_cop_measure", _points];

    if (count _points == 2) then {
        [_points call TC2_fnc_copMeasureText, [1, 0.9, 0.3, 1]] call TC2_fnc_copUiStatus;
    } else {
        ["  ÖLÇ: A işaretlendi, B noktasına tıklayın.", [0.25, 1, 0.35, 1]] call TC2_fnc_copUiStatus;
    };
};

if (_mode isEqualTo "INFO") exitWith {
    private _tolerance = ((_world distance2D (_map ctrlMapScreenToWorld [_x + 0.02, _y])) max 20);
    private _best = [];
    private _bestDistance = _tolerance;

    {
        private _distance = (_x select 0) distance2D _world;
        if (_x select 2 && {_distance <= _bestDistance}) then {
            _bestDistance = _distance;
            _best = _x;
        };
    } forEach ((missionNamespace getVariable ["TC2_cop_data", [[], [], []]]) select 0);

    private _panel = (ctrlParent _map) displayCtrl 92046;
    if (_best isEqualTo []) exitWith {
        _panel ctrlShow false;
        ["  Yakında dost lider yok (yalnızca liderler gösterilir).", [1, 0.8, 0.2, 1]] call TC2_fnc_copUiStatus;
    };

    _panel ctrlSetStructuredText parseText format ["<t size='0.8'>%1</t>", [_best select 1, _best select 3] call TC2_fnc_rptLaceText];
    _panel ctrlShow true;
};

if (_mode isEqualTo "PLACE") exitWith {
    private _args = [ACE_player, _terminal, _state, missionNamespace getVariable ["TC2_cop_placeType", "INF"], ATLToASL [_world select 0, _world select 1, 0]];
    if (isServer) then {_args call TC2_fnc_copPlace} else {_args remoteExecCall ["TC2_fnc_copPlace", 2]};
};

if (_mode isEqualTo "DELETE") exitWith {
    private _tolerance = ((_world distance2D (_map ctrlMapScreenToWorld [_x + 0.02, _y])) max 20);
    private _best = -1;
    private _bestDistance = _tolerance;

    {
        private _distance = (_x select 2) distance2D _world;
        if (_distance <= _bestDistance) then {
            _bestDistance = _distance;
            _best = _x select 0;
        };
    } forEach ((missionNamespace getVariable ["TC2_cop_data", [[], [], []]]) select 1);

    if (_best < 0) exitWith {
        ["  Yakında silinecek işaret yok.", [1, 0.8, 0.2, 1]] call TC2_fnc_copUiStatus;
    };

    private _args = [ACE_player, _terminal, _state, _best];
    if (isServer) then {_args call TC2_fnc_copRemove} else {_args remoteExecCall ["TC2_fnc_copRemove", 2]};
};
