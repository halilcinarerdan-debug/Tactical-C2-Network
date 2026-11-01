/*
    Fonksiyon: TC2_fnc_artyFdcAction
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_artyFdcAction", 2]
                  - host / tek oyunculuda: artyUiFdcAction doğrudan çağırır

    FDC operatörünün işlemleri. Doğrulamalar: gönderen, oturum, FDC rolü, görev bu FDC'ye adreslenmiş.
      ACCEPT   [batarya anahtarı, hacim (0 = CFF'tekini koru), değişiklikler (metin)]
               Batarya bu tarafın, kullanılabilir (oyuncu mürettebatlı), mühimmatı var, hedef menzilde (inRangeOfArtillery) olmalı.
               Hedef numarası verilir ve MTO gönderilir: birim(ler), değişiklikler, mermi sayısı, hedef no (ATP 3-09.30, 4-66..4-70).
               AT MY COMMAND ise "<batarya> IS READY" (gözlemci FIRE der); değilse atış başlar (FIRE WHEN READY).
      REJECT   [neden]       CFF reddedilir (CFF bir istektir, emir değildir; FDC karar verir).
      SHOT / SPLASH / COMPLETE   elle bildirim (yalnızca oyuncu bataryası olan görevlerde).
      CHECK    CHECK FIRING (acil durdurma).

    Parametreler:
        0: FDC birimi <OBJECT>
        1: terminal / saha cihazı <OBJECT>
        2: telsiz durumu <ARRAY>
        3: işlem <STRING>
        4: görev id <NUMBER>
        5: argümanlar <ARRAY>

    Dönüş: yok (yanıt: artyOnAck ve artyOnEvent)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_action", "", [""]], ["_id", -1, [0]], ["_args", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_artyOnAck", [_code, []]] call TC2_fnc_netToUnit;
};

if !([_unit, "FDC"] call TC2_fnc_hasRole) exitWith {
    diag_log format ["[TC2][TOPCU] RED NOT_FDC birim=%1", name _unit];
    [_unit, "TC2_fnc_artyOnAck", ["NOT_FDC", []]] call TC2_fnc_netToUnit;
};

private _index = [_id] call TC2_fnc_artyMissionIndex;
if (_index < 0) exitWith {
    [_unit, "TC2_fnc_artyOnAck", ["NOT_FOUND", []]] call TC2_fnc_netToUnit;
};

private _mission = (missionNamespace getVariable ["TC2_arty_missions", []]) select _index;
if !((_mission select 4) isEqualTo (netId _unit)) exitWith {
    diag_log format ["[TC2][TOPCU] RED gorev baska FDC'ye ait id=%1 birim=%2", _id, name _unit];
};

private _status = _mission select 7;
private _ack = {[_unit, "TC2_fnc_artyOnAck", _this] call TC2_fnc_netToUnit};

switch (_action) do {
    case "ACCEPT": {
        if !(_status isEqualTo "REQUEST") exitWith {["BAD_STATE", []] call _ack};

        _args params [["_batteryKey", "", [""]], ["_volume", 0, [0]], ["_changes", "", [""]]];

        private _battery = [];
        {
            if ((_x select 0) isEqualTo _batteryKey) exitWith {_battery = _x};
        } forEach ([side (group _unit)] call TC2_fnc_artyBatteries);

        if (_battery isEqualTo []) exitWith {["NO_BATTERY", []] call _ack};
        if ((_battery select 2) isEqualTo "EMPTY") exitWith {["NO_BATTERY", []] call _ack};
        if !(_battery select 4) exitWith {["NO_PLAYER_CREW", []] call _ack};

        private _guns = ((_battery select 3) apply {objectFromNetId _x}) select {!isNull _x && {alive _x}};
        private _data = _mission select 8;
        private _magazine = [_guns, _data select 11] call TC2_fnc_artyAmmo;

        if (_magazine isEqualTo "") exitWith {["NO_AMMO", [_data select 11]] call _ack};
        if !((ASLToAGL (_mission select 10)) inRangeOfArtillery [_guns, _magazine]) exitWith {["OUT_OF_RANGE", []] call _ack};

        private _targetCounter = (missionNamespace getVariable ["TC2_arty_targetCounter", 0]) + 1;
        missionNamespace setVariable ["TC2_arty_targetCounter", _targetCounter];
        private _targetNo = format ["AF%1", 1000 + _targetCounter];

        private _rounds = if (_volume >= 1) then {_volume min 10} else {_mission select 13};
        private _changesText = [_changes, 60] call TC2_fnc_netSanitize;

        _mission set [9, _targetNo];
        _mission set [12, _battery select 3];
        _mission set [13, _rounds];
        _mission set [23, _battery select 1];
        _mission set [24, _changesText];
        _mission set [25, _magazine];

        // MTO: birim(ler), CFF'ten değişiklikler, mermi sayısı, hedef numarası (+ gözlemci-hedef yönü)
        private _mto = format [
            "MTO, %1, %2, %3 ROUNDS, TARGET %4, BREAK, DIRECTION %5, OVER.",
            _battery select 1, ["CFF AYNEN", _changesText] select !(_changesText isEqualTo ""), _rounds, _targetNo, _mission select 11
        ];
        [_id, _mto, "GOOD"] call TC2_fnc_artyEvent;

        diag_log format ["[TC2][TOPCU] KABUL id=%1 | fdc=%2 | batarya=%3 | hedef=%4 | mermi=%5 | mag=%6", _id, name _unit, _battery select 1, _targetNo, _rounds, _magazine];

        if ((_data select 13) isEqualTo "AMC") then {
            _mission set [7, "READY"];
            [_id, format ["%1 IS READY, OVER.", _battery select 1], "GOOD"] call TC2_fnc_artyEvent;
        } else {
            [_id] call TC2_fnc_artyExecute;
        };

        ["ACCEPTED", [_targetNo]] call _ack;
    };

    case "REJECT": {
        if !(_status in ["REQUEST", "READY"]) exitWith {["BAD_STATE", []] call _ack};
        private _reason = [(_args param [0, "", [""]]), 60] call TC2_fnc_netSanitize;
        _mission set [7, "REJECTED"];
        [_id, format ["CFF REDDEDİLDİ: %1", ["neden belirtilmedi", _reason] select !(_reason isEqualTo "")], "BAD"] call TC2_fnc_artyEvent;
        diag_log format ["[TC2][TOPCU] RED id=%1 | fdc=%2 | neden=%3", _id, name _unit, _reason];
        ["REJECTED", []] call _ack;
    };

    case "SHOT": {
        if (!(_status isEqualTo "FIRING") || {!(_mission select 21)}) exitWith {["BAD_STATE", []] call _ack};
        [_id, "SHOT, OUT.", "GOOD"] call TC2_fnc_artyEvent;
    };

    case "SPLASH": {
        if (!(_status isEqualTo "FIRING") || {!(_mission select 21)}) exitWith {["BAD_STATE", []] call _ack};
        [_id, "SPLASH, OVER.", "GOOD"] call TC2_fnc_artyEvent;
    };

    case "COMPLETE": {
        if (!(_status isEqualTo "FIRING") || {!(_mission select 21)}) exitWith {["BAD_STATE", []] call _ack};
        [_id, "DONE"] call TC2_fnc_artyComplete;
    };

    case "CHECK": {
        if !(_status in ["FIRING", "READY"]) exitWith {["BAD_STATE", []] call _ack};
        [_id, "CHECK"] call TC2_fnc_artyComplete;
    };

    default {};
};
