/*
    Fonksiyon: TC2_fnc_artyUiRequest
    Çalışma yeri: İSTEMCİ

    TOPÇU / FDC sekmesi verisini ister (artyPoll). Sekmeler seçilince, açıkken 5 sn'de bir (uiWatch) ve her olay/ack sonrası çağrılır.
    Pencere/terminal yoksa ya da bu sekmeler açık değilse hiçbir şey yapmaz (gereksiz ağ trafiği olmaz).

    Parametreler: yok
    Dönüş: yok
*/

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _terminal || {isNull (findDisplay 92000)}) exitWith {};
if !((missionNamespace getVariable ["TC2_ui_tab", 0]) in [3, 4]) exitWith {};

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState];

if (isServer) then {
    _args call TC2_fnc_artyPoll;
} else {
    _args remoteExecCall ["TC2_fnc_artyPoll", 2];
};
