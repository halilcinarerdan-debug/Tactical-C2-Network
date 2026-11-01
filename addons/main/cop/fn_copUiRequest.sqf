/*
    Fonksiyon: TC2_fnc_copUiRequest
    Çalışma yeri: İSTEMCİ

    Harita verisi ister (copRequest). HARİTA sekmesi seçilince, işlem sonrası ve sekme açıkken 5 sn'de bir
    (uiWatch) çağrılır. Pencere ya da terminal yoksa bir şey yapmaz.

    Parametreler: yok
    Dönüş: yok
*/

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _terminal || {isNull (findDisplay 92000)}) exitWith {};

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState];

if (isServer) then {
    _args call TC2_fnc_copRequest;
} else {
    _args remoteExecCall ["TC2_fnc_copRequest", 2];
};
