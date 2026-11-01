/*
    Fonksiyon: TC2_fnc_uiOnUnload
    Çalışma yeri: İstemci (terminal penceresinin "Unload" olayı; hangi yolla kapanırsa kapansın)

    Temizlik: izleme PFH'sini kaldırır, aktif terminal bilgisini siler, kapanış olayını yayınlar.

    Parametreler: yok
    Dönüş: yok
*/

private _handle = missionNamespace getVariable ["TC2_ui_watchHandle", -1];
if (_handle >= 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
};
missionNamespace setVariable ["TC2_ui_watchHandle", -1];

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
missionNamespace setVariable ["TC2_terminal_current", objNull];

// Ağ oturumunu kapat (sunucu kaydından düşer; artık mesaj almaz).
if (!isNull _terminal) then {
    [_terminal, [], true] call TC2_fnc_netReportState;
};
missionNamespace setVariable ["TC2_net_status", []];
missionNamespace setVariable ["TC2_cop_mode", ""];

["TC2_terminalClosed", [_terminal]] call CBA_fnc_localEvent;
