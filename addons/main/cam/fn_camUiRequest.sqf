/*
    Fonksiyon: TC2_fnc_camUiRequest
    Çalışma yeri: İSTEMCİ

    Kamera kaynak listesini ister (camPoll). KAMERA sekmesi seçilince ve açıkken 5 sn'de bir (uiWatch) çağrılır.
    Pencere/terminal yoksa ya da sekme açık değilse bir şey yapmaz.

    Parametreler: yok
    Dönüş: yok
*/

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _terminal || {isNull (findDisplay 92000)}) exitWith {};
if ((missionNamespace getVariable ["TC2_ui_tab", 0]) != 9) exitWith {};

// İlk istek zamanı: sunucudan hiç yanıt gelmezse (örn. sunucuda TC2 güncel değil) arayüz bunu söyler.
if ((missionNamespace getVariable ["TC2_cam_reqTime", -1]) < 0) then {missionNamespace setVariable ["TC2_cam_reqTime", diag_tickTime]};

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState];

if (isServer) then {
    _args call TC2_fnc_camPoll;
} else {
    _args remoteExecCall ["TC2_fnc_camPoll", 2];
};
