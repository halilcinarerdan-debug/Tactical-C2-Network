/*
    Fonksiyon: TC2_fnc_medUiSend
    Çalışma yeri: İSTEMCİ (TALEBİ GÖNDER düğmesi)

    Formu okur, yerelde denetler (anında geri bildirim; asıl denetim sunucuda medValidate ile tekrarlanır) ve sunucuya gönderir.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _display || {isNull _terminal}) exitWith {};

private _pick = {
    private _control = _display displayCtrl _this;
    _control lbData (lbCurSel _control)
};

private _data = [
    92810 call _pick, ctrlText (_display displayCtrl 92811),
    92812 call _pick, 92813 call _pick, 92814 call _pick, 92815 call _pick, 92816 call _pick,
    92817 call _pick, 92818 call _pick, 92819 call _pick,
    92820 call _pick, 92821 call _pick, 92822 call _pick, 92823 call _pick
];

private _check = [_data] call TC2_fnc_medValidate;
if !(_check select 0) exitWith {
    private _text = (_check select 1) joinString " ";
    missionNamespace setVariable ["TC2_med_statusText", _text];
    [_text, "error"] call TC2_fnc_notify;
    call TC2_fnc_medUiUpdate;
};

missionNamespace setVariable ["TC2_med_statusText", "Gönderiliyor..."];
call TC2_fnc_medUiUpdate;

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState, _data];
if (isServer) then {
    _args call TC2_fnc_medSend;
} else {
    _args remoteExecCall ["TC2_fnc_medSend", 2];
};
