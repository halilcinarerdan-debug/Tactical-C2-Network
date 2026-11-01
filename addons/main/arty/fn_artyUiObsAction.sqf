/*
    Fonksiyon: TC2_fnc_artyUiObsAction
    Çalışma yeri: İSTEMCİ (panel B düğmeleri)

    Gözlemcinin görev işlemini sunucuya gönderir: CORRECT (düzeltme), REPEAT, FIRE, CHECK, EOM. Alanlar boşsa düzeltme sıfır / "aynı" kabul edilir.
    Karar ve kuralları (DANGER CLOSE, creeping fire, minör sapma) sunucu uygular.

    Parametreler:
        0: işlem <STRING>

    Dönüş: yok
*/

params [["_action", "", [""]]];

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
private _display = findDisplay 92000;
if (isNull _terminal || {isNull _display}) exitWith {};

private _mine = ((missionNamespace getVariable ["TC2_arty_data", [false, false, [], [], [], [], []]]) select 3);
if (_mine isEqualTo []) exitWith {};

private _text = {ctrlText (_display displayCtrl _this)};
private _number = {private _value = ctrlText (_display displayCtrl _this); if (_value isEqualTo "") then {0} else {parseNumber _value}};
private _selected = {private _control = _display displayCtrl _this; _control lbData (lbCurSel _control)};

private _args = [];
switch (_action) do {
    case "CORRECT": {
        private _directionText = 92430 call _text;
        _args = [
            if (_directionText isEqualTo "") then {-1} else {parseNumber _directionText},
            92431 call _number, 92432 call _number, 92433 call _number,
            92434 call _selected, parseNumber (92435 call _selected)
        ];
    };
    case "EOM": {
        _args = [92440 call _text, (92441 call _selected) isEqualTo "1"];
    };
    default {};
};

private _call = [ACE_player, _terminal, call TC2_fnc_netGetRadioState, _action, _mine select 0, _args];

if (isServer) then {
    _call call TC2_fnc_artyObsAction;
} else {
    _call remoteExecCall ["TC2_fnc_artyObsAction", 2];
};
