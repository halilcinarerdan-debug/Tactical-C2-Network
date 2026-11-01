/*
    Fonksiyon: TC2_fnc_rptUiSend
    Çalışma yeri: İSTEMCİ (GÖNDER düğmesi)

    Formu okur, yerelde denetler (anında geri bildirim; asıl denetim sunucuda rptValidate ile tekrarlanır) ve sunucuya gönderir.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _display || {isNull _terminal}) exitWith {};

private _type = missionNamespace getVariable ["TC2_rpt_type", "SALUTE"];
private _edit = {ctrlText (_display displayCtrl _this)};
private _pick = {
    private _control = _display displayCtrl _this;
    _control lbData (lbCurSel _control)
};

private _data = switch (_type) do {
    case "SALUTE": {[92720 call _edit, 92721 call _edit, 92716 call _pick, 92723 call _edit, 92724 call _edit, 92725 call _edit]};
    case "SITREP": {[92720, 92721, 92722, 92723, 92724, 92725] apply {_x call _edit}};
    default {
        private _out = [];
        for "_k" from 0 to 3 do {
            _out pushBack ((92710 + _k) call _pick);
            _out pushBack ((92720 + _k) call _edit);
        };
        _out
    };
};

private _check = [_type, _data] call TC2_fnc_rptValidate;
if !(_check select 0) exitWith {
    private _text = (_check select 1) joinString " ";
    missionNamespace setVariable ["TC2_rpt_statusText", _text];
    [_text, "error"] call TC2_fnc_notify;
    call TC2_fnc_rptUiUpdate;
};

missionNamespace setVariable ["TC2_rpt_statusText", "Gönderiliyor..."];
call TC2_fnc_rptUiUpdate;

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState, _type, _data];
if (isServer) then {
    _args call TC2_fnc_rptSend;
} else {
    _args remoteExecCall ["TC2_fnc_rptSend", 2];
};
