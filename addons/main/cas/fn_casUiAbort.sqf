/*
    Fonksiyon: TC2_fnc_casUiAbort
    Çalışma yeri: İSTEMCİ (İPTAL düğmesi)

    Etkin talebi iptal eder (JTAC iptal yetkisi). Etkin talep yoksa ya da zaten iptal edilmişse bir şey yapmaz.

    Parametreler: yok
    Dönüş: yok
*/

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _terminal) exitWith {};

private _summary = (missionNamespace getVariable ["TC2_cas_data", [false, [], []]]) select 2;

if (_summary isEqualTo [] || {(_summary select 1) isEqualTo "ABORTED"}) exitWith {
    missionNamespace setVariable ["TC2_cas_statusText", "İptal edilecek etkin talep yok."];
    call TC2_fnc_casUiUpdate;
};

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState, _summary select 0];

if (isServer) then {
    _args call TC2_fnc_casAbort;
} else {
    _args remoteExecCall ["TC2_fnc_casAbort", 2];
};
