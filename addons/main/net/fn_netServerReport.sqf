/*
    Fonksiyon: TC2_fnc_netServerReport
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_netServerReport", 2]
                  - host / tek oyunculuda: netReportState doğrudan çağırır

    İstemci, terminal oturumunun telsiz durumunu bildirir (açılışta, durum değişince, açıkken 5 sn'de bir)
    ya da oturumu kapattığını söyler. Sunucu oturumu doğrular (netServerSession), ulaşılabilir eşleri
    sayar ve istemciye BAĞLANTI durumunu geri yollar (netOnStatus).

    Parametreler:
        0: birim <OBJECT>
        1: terminal <OBJECT>
        2: telsiz durumu <ARRAY>  (netGetRadioState)
        3: oturum kapanıyor mu <BOOL> (varsayılan false)

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_closing", false, [false]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

if (_closing) exitWith {
    private _netId = netId _unit;
    missionNamespace setVariable ["TC2_net_sessions", (missionNamespace getVariable ["TC2_net_sessions", []]) select {(_x select 0) != _netId}];
};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok) exitWith {
    [_unit, "TC2_fnc_netOnStatus", [_code, 0, "", -1]] call TC2_fnc_netToUnit;
};

private _peers = [_entry] call TC2_fnc_netServerPeers;

private _status = _code;
if (_code isEqualTo "OK") then {
    _status = if (_peers isEqualTo []) then {"NO_PEERS"} else {"LINK"};
};

[_unit, "TC2_fnc_netOnStatus", [_status, count _peers, _entry select 4, _entry select 5]] call TC2_fnc_netToUnit;
