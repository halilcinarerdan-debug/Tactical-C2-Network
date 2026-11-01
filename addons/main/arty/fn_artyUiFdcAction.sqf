/*
    Fonksiyon: TC2_fnc_artyUiFdcAction
    Çalışma yeri: İSTEMCİ (FDC sekmesi düğmeleri)

    FDC operatörünün işlemini sunucuya gönderir: ACCEPT (batarya + mermi + değişiklikler), REJECT (neden), SHOT, SPLASH, COMPLETE, CHECK.
    Görev, kuyruk listesinde seçili olandır. Karar ve doğrulamalar (menzil, mühimmat, AI ayarı) sunucuda.

    Parametreler:
        0: işlem <STRING>

    Dönüş: yok
*/

params [["_action", "", [""]]];

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
private _display = findDisplay 92000;
if (isNull _terminal || {isNull _display}) exitWith {};

private _queueControl = _display displayCtrl 92450;
private _id = parseNumber (_queueControl lbData (lbCurSel _queueControl));
if (_id <= 0) exitWith {
    missionNamespace setVariable ["TC2_arty_statusText", "Önce kuyruktan bir görev seçin."];
    call TC2_fnc_artyUiUpdate;
};

private _args = [];
switch (_action) do {
    case "ACCEPT": {
        private _batteryControl = _display displayCtrl 92452;
        private _roundsText = ctrlText (_display displayCtrl 92453);
        _args = [
            _batteryControl lbData (lbCurSel _batteryControl),
            if (_roundsText isEqualTo "") then {0} else {parseNumber _roundsText},
            ctrlText (_display displayCtrl 92454)
        ];
    };
    case "REJECT": {
        _args = [ctrlText (_display displayCtrl 92457)];
    };
    default {};
};

private _call = [ACE_player, _terminal, call TC2_fnc_netGetRadioState, _action, _id, _args];

if (isServer) then {
    _call call TC2_fnc_artyFdcAction;
} else {
    _call remoteExecCall ["TC2_fnc_artyFdcAction", 2];
};
