/*
    Fonksiyon: TC2_fnc_netSend
    Çalışma yeri: İSTEMCİ

    Mesaj / PING / PONG gönderir. İstemci tarafı kontrol yalnızca kolaylıktır (boş metin, 2 sn bekleme);
    asıl ağ kuralları (telsiz, kanal, menzil, gönderim aralığı) sunucuda uygulanır.

    Parametreler:
        0: tür <STRING>         "MSG" (varsayılan) | "PING" | "PONG"
        1: metin <STRING>       (MSG için)
        2: hedef netId <STRING> (yalnızca PONG için)

    Dönüş: yok
*/

params [["_type", "MSG", [""]], ["_text", "", [""]], ["_target", "", [""]]];

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _terminal) exitWith {};

private _wait = (_type != "PONG") && {diag_tickTime < (missionNamespace getVariable ["TC2_net_nextSend", 0])};
if (_wait) exitWith {
    ["Bekleyin (2 sn aralık).", "#ffcc33"] call TC2_fnc_netLog;
};

private _clean = [_text] call TC2_fnc_netSanitize;
if (_type isEqualTo "MSG" && {_clean isEqualTo ""}) exitWith {};

if (_type != "PONG") then {
    missionNamespace setVariable ["TC2_net_nextSend", diag_tickTime + 2];
    // Gönderilen metin saklanır; günlüğe SUNUCU onaylayınca (netOnAck) yazılır. Böylece gitmeyen mesaj gitmiş gibi görünmez.
    missionNamespace setVariable ["TC2_net_pendingText", _clean];
};

private _state = call TC2_fnc_netGetRadioState;
missionNamespace setVariable ["TC2_net_lastState", _state];
missionNamespace setVariable ["TC2_net_lastReport", diag_tickTime];

private _args = [ACE_player, _terminal, _state, _type, _clean, _target];

if (isServer) then {
    _args call TC2_fnc_netServerSend;
} else {
    _args remoteExecCall ["TC2_fnc_netServerSend", 2];
};
