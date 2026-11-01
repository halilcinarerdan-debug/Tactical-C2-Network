/*
    Fonksiyon: TC2_fnc_rptUiRequest
    Çalışma yeri: İSTEMCİ

    RAPOR verisini ister (rptPoll) ve SALUTE konum listesi için işaret verisini yeniler (copRequest). RAPOR sekmesi seçilince,
    açıkken 5 sn'de bir (uiWatch) ve her ack sonrası çağrılır. Pencere/terminal yoksa ya da sekme açık değilse bir şey yapmaz.

    Parametreler: yok
    Dönüş: yok
*/

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _terminal || {isNull (findDisplay 92000)}) exitWith {};
if ((missionNamespace getVariable ["TC2_ui_tab", 0]) != 6) exitWith {};

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState];

if (isServer) then {
    _args call TC2_fnc_rptPoll;
    _args call TC2_fnc_copRequest;
} else {
    _args remoteExecCall ["TC2_fnc_rptPoll", 2];
    _args remoteExecCall ["TC2_fnc_copRequest", 2];
};
