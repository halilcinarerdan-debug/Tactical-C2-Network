/*
    Fonksiyon: TC2_fnc_casReadback
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_casReadback", 2]
                  - host / tek oyunculuda: casPilotReadback doğrudan çağırır

    Pilotun geri okumasını alır. Doğrulamalar: gönderen (remoteExecutedOwner), talep var ve bu birim alıcı,
    talep iptal edilmemiş, pilotun telsizi envanterde ve JTAC ile aynı ağda/menzilde (geri okuma da telsizle yapılır).
    Karşılaştırma ve bildirim casApplyReadback'te.

    Parametreler:
        0: pilot birimi <OBJECT>
        1: telsiz durumu <ARRAY>
        2: talep id <NUMBER>
        3: cevaplar <ARRAY>  [yükseklik, konum, FAH, danger close, ACA, TOT]

    Dönüş: yok (sonuç: casOnResult; reddedilirse casOnAck ile neden)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_state", [], [[]]], ["_id", -1, [0]], ["_answers", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _index = [_id] call TC2_fnc_casReqIndex;
if (_index < 0) exitWith {
    [_unit, "TC2_fnc_casOnAck", ["NOT_FOUND", []]] call TC2_fnc_netToUnit;
};

private _request = (missionNamespace getVariable ["TC2_cas_requests", []]) select _index;

if (!((_request select 3) isEqualTo (netId _unit)) || {_request select 14}) exitWith {
    diag_log format ["[TC2][CAS] GERI OKUMA RED id=%1 | alici degil: %2", _id, name _unit];
};
if ((_request select 7) isEqualTo "ABORTED") exitWith {
    [_unit, "TC2_fnc_casOnAck", ["ABORTED", []]] call TC2_fnc_netToUnit;
};

// Pilotun telsizi: envanterde, JTAC ile aynı tip + kanal, JTAC'ın menzili içinde.
_state params [["_has", false, [false]], ["_radioId", "", [""]], ["_base", "", [""]], ["_channel", -1, [0]]];
private _radioOk = _has && {(toLower _radioId) in ((items _unit) apply {toLower _x})};
private _netOk = _radioOk && {_base isEqualTo (_request select 10)} && {_channel == (_request select 11)} && {(_unit distance (_request select 2)) <= ([_base] call TC2_fnc_netRangeOf)};

if (!_netOk) exitWith {
    [_unit, "TC2_fnc_casOnAck", [["NO_RADIO", "NO_LINK"] select _radioOk, []]] call TC2_fnc_netToUnit;
};

[_id, _answers] call TC2_fnc_casApplyReadback;
