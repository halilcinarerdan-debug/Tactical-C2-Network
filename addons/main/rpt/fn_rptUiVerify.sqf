/*
    Fonksiyon: TC2_fnc_rptUiVerify
    Çalışma yeri: İSTEMCİ (DOĞRULA düğmesi; yalnızca S2 / CO için görünür, yetki sunucuda yeniden denetlenir)

    Gelen kutusunda seçili SALUTE raporunu doğrulatır.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _display || {isNull _terminal}) exitWith {};

private _inbox = _display displayCtrl 92730;
private _id = parseNumber (_inbox lbData (lbCurSel _inbox));
if (_id <= 0) exitWith {
    missionNamespace setVariable ["TC2_rpt_statusText", "Önce listeden bir SALUTE raporu seçin."];
    call TC2_fnc_rptUiUpdate;
};

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState, _id];
if (isServer) then {
    _args call TC2_fnc_rptVerify;
} else {
    _args remoteExecCall ["TC2_fnc_rptVerify", 2];
};
