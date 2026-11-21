/*
    Fonksiyon: TC2_fnc_virtCasStart
    Çalışma yeri: SADECE SUNUCU (casSend, sanal pilotun geri okuması DOĞRU tamamlanınca çağırır)

    Sanal CAS sortisini başlatır: tarafın sanal CAS'ını meşgul işaretler, JTAC'a "uçak yolda" bilgisi verir ve kalkış / yaklaşma gecikmesinden sonra
    virtCasRun ile uçağı sahaya sokar. Talep o sırada iptal edilirse (ABORT) sortie hiç başlamaz.

    Parametreler:
        0: talep id <NUMBER>

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_id", -1, [0]]];

private _index = [_id] call TC2_fnc_casReqIndex;
if (_index < 0) exitWith {};

private _request = (missionNamespace getVariable ["TC2_cas_requests", []]) select _index;
if !((_request select 7) isEqualTo "READBACK_OK") exitWith {};

private _side = side (group (_request select 2));
missionNamespace setVariable [format ["TC2_virt_casBusy_%1", str _side], true];

private _delay = missionNamespace getVariable ["TC2_virt_casDelay", 45];
private _jtacNet = _request select 1;
private _data = _request select 5;

[_jtacNet, format ["SANAL CAS #%1: uçak yolda, tahmini %2 sn (TYPE %3, atak yönü %4°)", _id, round _delay, _data select 0, if ((_data select 15) >= 0) then {_data select 15} else {_data select 3}]] call TC2_fnc_netInfo;
diag_log format ["[TC2][VIRT] CAS baslatildi id=%1 | gecikme=%2 | taraf=%3", _id, _delay, _side];

[{
    params ["_id"];
    [_id] call TC2_fnc_virtCasRun;
}, [_id], _delay] call CBA_fnc_waitAndExecute;
