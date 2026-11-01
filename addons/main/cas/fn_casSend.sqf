/*
    Fonksiyon: TC2_fnc_casSend
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_casSend", 2]
                  - host / tek oyunculuda: casUiSend doğrudan çağırır

    9-Line CAS talebini pilota iletir. Sunucu doğrulamaları (hepsi zorunlu):
      1. gönderen (remoteExecutedOwner), 2. oturum (kart, 5 m, telsiz envanterde), 3. JTAC yetkisi (TC2_fnc_isJtac: Zeus/Eden ataması, rol açıklaması, sınıf),
      4. alıcı gerçekten JTAC'ın ağında, menzilde ve hava aracında (casTargets),
      5. form doktrine uygun (casValidate; platforma göre nm/m), 6. gönderim aralığı (3 sn).
    Her JTAC'ın tek etkin talebi vardır; yenisi eskisini iptal eder (eski pilota bildirilir).
    Başarıda pilota casOnIncoming gider; JTAC'a ack. Her işlem RPT'ye "[TC2][CAS]".

    Parametreler:
        0: JTAC birimi <OBJECT>
        1: terminal <OBJECT>
        2: telsiz durumu <ARRAY>
        3: form verisi <ARRAY>
        4: alıcı netId <STRING>

    Dönüş: yok (yanıt: casOnAck)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_data", [], [[]]], ["_targetNet", "", [""]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_casOnAck", [_code, []]] call TC2_fnc_netToUnit;
};

if !([_unit, _terminal, "CAS"] call TC2_fnc_canWriteFires) exitWith {
    diag_log format ["[TC2][CAS] RED NOT_JTAC birim=%1", name _unit];
    [_unit, "TC2_fnc_casOnAck", ["NOT_JTAC", []]] call TC2_fnc_netToUnit;
};

// Serbest metin alanlarını temizle ('<', '>', '&' atılır): pilota structured text olarak gösterilecek.
_data = _data apply {if (_x isEqualType "") then {[_x, 100] call TC2_fnc_netSanitize} else {_x}};

private _now = diag_tickTime;
if ((_now - (_entry select 8)) < 3) exitWith {
    [_unit, "TC2_fnc_casOnAck", ["COOLDOWN", []]] call TC2_fnc_netToUnit;
};

private _base = _entry select 4;
private _channel = _entry select 5;

private _target = [];
{
    if ((_x select 0) isEqualTo _targetNet) exitWith {_target = _x};
} forEach ([_unit, _base, _channel] call TC2_fnc_casTargets);

if (_target isEqualTo []) exitWith {
    [_unit, "TC2_fnc_casOnAck", ["NO_TARGET", []]] call TC2_fnc_netToUnit;
};

_target params ["", "_pilotLabel", "_platform", "", "_sim"];

private _validation = [_data, _platform] call TC2_fnc_casValidate;
if !(_validation select 0) exitWith {
    [_unit, "TC2_fnc_casOnAck", ["INVALID", _validation select 1]] call TC2_fnc_netToUnit;
};

_entry set [8, _now];

// Bu JTAC'ın eski etkin talebini iptal et (tek etkin talep kuralı).
private _jtacNet = netId _unit;
private _requests = missionNamespace getVariable ["TC2_cas_requests", []];
{
    if ((_x select 1) isEqualTo _jtacNet && {!((_x select 7) isEqualTo "ABORTED")}) then {
        _x set [7, "ABORTED"];
        if (!(_x select 14) && {!isNull (_x select 4)}) then {
            [_x select 4, "TC2_fnc_casOnResult", [_x select 0, "ABORTED", _x select 8]] call TC2_fnc_netToUnit;
        };
    };
} forEach _requests;

private _id = (missionNamespace getVariable ["TC2_cas_nextId", 0]) + 1;
missionNamespace setVariable ["TC2_cas_nextId", _id];

private _pilotUnit = objectFromNetId _targetNet;
private _simWrong = false;
{
    if ((_x select 0) isEqualTo _targetNet) exitWith {_simWrong = _x select 5};
} forEach (missionNamespace getVariable ["TC2_cas_simPilots", []]);

private _jtacCallsign = [groupId (group _unit), 24] call TC2_fnc_netSanitize;
private _pilotCallsign = if (_sim) then {_pilotLabel} else {[groupId (group _pilotUnit), 24] call TC2_fnc_netSanitize};

_requests pushBack [_id, _jtacNet, _unit, _targetNet, _pilotUnit, _data, _platform, "SENT", [], _now, _base, _channel, _jtacCallsign, _pilotCallsign, _sim, _simWrong];
missionNamespace setVariable ["TC2_cas_requests", _requests];

diag_log format ["[TC2][CAS] GONDERILDI id=%1 | type=%2 %3 | jtac=%4 | alici=%5 (%6) | ag=%7 K%8", _id, _data select 0, _data select 1, name _unit, _pilotLabel, _platform, _base, _channel];

[_unit, "TC2_fnc_casOnAck", ["SENT", [_id, _pilotLabel]]] call TC2_fnc_netToUnit;

// Üs bilgisi: ağdaki terminaller / saha cihazları bu 9-Line'ın gönderildiğini günlüklerinde görür.
[_jtacNet, format ["CAS #%1  JTAC %2  alıcı %3  TYPE %4 %5", _id, _jtacCallsign, _pilotCallsign, _data select 0, _data select 1]] call TC2_fnc_netInfo;

if (_sim) then {
    // Simüle pilot: 3 sn sonra geri okur (doğru ya da bilerek yanlış).
    [{
        params ["_id"];
        private _index = [_id] call TC2_fnc_casReqIndex;
        if (_index < 0) exitWith {};
        private _request = (missionNamespace getVariable ["TC2_cas_requests", []]) select _index;
        if ((_request select 7) isEqualTo "ABORTED") exitWith {};
        private _data = _request select 5;
        private _wrong = _request select 15;
        [_id, [
            _data select 6,
            if (_wrong) then {"00000 00000"} else {[_data select 8] call TC2_fnc_casGrid},
            _data select 15, _data select 17, _data select 16, _data select 18
        ]] call TC2_fnc_casApplyReadback;
    }, [_id], 3] call CBA_fnc_waitAndExecute;
} else {
    [_pilotUnit, "TC2_fnc_casOnIncoming", [_id, _jtacCallsign, _pilotCallsign, _data, _platform, "SENT", []]] call TC2_fnc_netToUnit;
};
