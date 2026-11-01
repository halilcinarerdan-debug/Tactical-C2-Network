/*
    Fonksiyon: TC2_fnc_netServerSend
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_netServerSend", 2]
                  - host / tek oyunculuda: netSend doğrudan çağırır

    Mesaj / PING / PONG gönderimi. Ağ kuralı sunucuda uygulanır:
      1. gönderen doğrulanır (remoteExecutedOwner),
      2. oturum doğrulanır (kart, mesafe, telsiz envanterde mi),
      3. telsiz yoksa            -> ack NO_RADIO / NO_ACRE  ("BAĞLANTI YOK")
      4. aynı tip+kanalda menzil içinde eş yoksa -> ack NO_PEERS ("BAĞLANTI YOK")
      5. eşlere netReceive ile iletilir; gönderene ack SENT + eş sayısı.

    Tür: "MSG" (metin), "PING" (ağdaki herkesten PONG ister), "PONG" (yalnızca hedef netId'ye yanıt).
    Gönderim aralığı (MSG/PING): 2 sn (spam önlemi). Metin temizlenir ve 120 karaktere kısaltılır.
    Her gönderim RPT'ye "[TC2][NET]" olarak kaydedilir.

    Parametreler:
        0: birim <OBJECT>
        1: terminal <OBJECT>
        2: telsiz durumu <ARRAY>
        3: tür <STRING>
        4: metin <STRING>
        5: hedef netId <STRING>  (yalnızca PONG için)

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [
    ["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]],
    ["_type", "MSG", [""]], ["_text", "", [""]], ["_target", "", [""]]
];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

_type = toUpper _type;
if !(_type in ["MSG", "PING", "PONG"]) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

// PONG'a ack gönderilmez (ağ trafiğini azaltmak için).
private _wantAck = _type != "PONG";

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    if (_wantAck) then {[_unit, "TC2_fnc_netOnAck", [_type, _code, 0]] call TC2_fnc_netToUnit};
};

if ((_entry param [9, "DESK"]) isEqualTo "VIEW") exitWith {
    if (_wantAck) then {[_unit, "TC2_fnc_netOnAck", [_type, "VIEW_ONLY", 0]] call TC2_fnc_netToUnit};
};

private _now = diag_tickTime;
if (_wantAck && {(_now - (_entry select 8)) < 2}) exitWith {
    [_unit, "TC2_fnc_netOnAck", [_type, "COOLDOWN", 0]] call TC2_fnc_netToUnit;
};

private _clean = [_text] call TC2_fnc_netSanitize;
if (_type isEqualTo "MSG" && {_clean isEqualTo ""}) exitWith {};

private _peers = [_entry] call TC2_fnc_netServerPeers;
if (_type isEqualTo "PONG") then {
    _peers = _peers select {(_x select 0) isEqualTo _target};
};

if (_peers isEqualTo []) exitWith {
    diag_log format ["[TC2][NET] %1 NO_PEERS | gonderen=%2 | tip=%3 kanal=%4 | menzil=%5 m | kayitli oturum=%6", _type, name _unit, _entry select 4, _entry select 5, [_entry select 4] call TC2_fnc_netRangeOf, count (missionNamespace getVariable ["TC2_net_sessions", []])];
    if (_wantAck) then {[_unit, "TC2_fnc_netOnAck", [_type, "NO_PEERS", 0]] call TC2_fnc_netToUnit};
};

if (_wantAck) then {_entry set [8, _now]};

private _netId = _entry select 0;
private _from = [format ["%1 / %2", name _unit, _entry select 2], 60] call TC2_fnc_netSanitize;

diag_log format [
    "[TC2][NET] %1 | gonderen=%2 (%3) | esler=%4 | kanal=%5 %6 | menzil=%7 m | mesafeler=%8 | metin=%9",
    _type, name _unit, _entry select 2, count _peers, _entry select 4, _entry select 5,
    [_entry select 4] call TC2_fnc_netRangeOf,
    _peers apply {round (_unit distance (_x select 1))},
    _clean
];

{
    private _peer = _x;
    private _distance = round (_unit distance (_peer select 1));

    if (_peer select 7) then {
        // Simüle test eşi (debugNetPeer): gerçek istemci yok, sunucu davranır.
        diag_log format ["[TC2][NET] SIM-ES %1 aldi: %2 '%3'", _peer select 2, _type, _clean];
        if (_type isEqualTo "PING") then {
            [_unit, "TC2_fnc_netReceive", ["PONG", _peer select 2, "", _distance, _peer select 0]] call TC2_fnc_netToUnit;
        };
    } else {
        [_peer select 1, "TC2_fnc_netReceive", [_type, _from, _clean, _distance, _netId]] call TC2_fnc_netToUnit;
    };
} forEach _peers;

if (_wantAck) then {
    [_unit, "TC2_fnc_netOnAck", [_type, "SENT", count _peers]] call TC2_fnc_netToUnit;
};
