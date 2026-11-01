/*
    Fonksiyon: TC2_fnc_netReportState
    Çalışma yeri: İSTEMCİ

    Telsiz durumunu sunucuya bildirir (ya da oturumun kapandığını söyler). Host / tek oyunculuda
    sunucu aynı makine olduğu için doğrudan çağrılır, uzak istemcide remoteExecCall ile YALNIZCA sunucuya gider.

    Parametreler:
        0: terminal <OBJECT>
        1: telsiz durumu <ARRAY>  (netGetRadioState)
        2: oturum kapanıyor mu <BOOL> (varsayılan false)

    Dönüş: yok
*/

params [["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_closing", false, [false]]];

missionNamespace setVariable ["TC2_net_lastState", _state];
missionNamespace setVariable ["TC2_net_lastReport", diag_tickTime];

private _args = [ACE_player, _terminal, _state, _closing];

if (isServer) then {
    _args call TC2_fnc_netServerReport;
} else {
    _args remoteExecCall ["TC2_fnc_netServerReport", 2];
};
