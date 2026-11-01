/*
    Fonksiyon: TC2_fnc_casUiRequest
    Çalışma yeri: İSTEMCİ

    CAS sekmesi verisini ister (casPoll): alıcı listesi ve etkin talep durumu. CAS sekmesi seçilince ve sekme
    açıkken 5 sn'de bir (uiWatch) çağrılır. Pencere/terminal yoksa bir şey yapmaz.

    Parametreler: yok
    Dönüş: yok
*/

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _terminal || {isNull (findDisplay 92000)}) exitWith {};

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState];

if (isServer) then {
    _args call TC2_fnc_casPoll;
} else {
    _args remoteExecCall ["TC2_fnc_casPoll", 2];
};
