/*
    Fonksiyon: TC2_fnc_casApplyReadback
    Çalışma yeri: SADECE SUNUCU

    Pilotun geri okumasını karşılaştırır (casCompare), talebin durumunu günceller ve sonucu hem JTAC'a hem
    (gerçek) pilota gönderir. Hepsi doğruysa "READBACK_OK", biri yanlışsa "READBACK_FAIL" (pilot tekrar okuyabilir).

    Parametreler:
        0: talep id <NUMBER>
        1: cevaplar <ARRAY>  (bkz. casCompare)

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_id", -1, [0]], ["_answers", [], [[]]]];

private _index = [_id] call TC2_fnc_casReqIndex;
if (_index < 0) exitWith {};

private _request = (missionNamespace getVariable ["TC2_cas_requests", []]) select _index;
if ((_request select 7) isEqualTo "ABORTED") exitWith {};

private _results = [_request select 5, _answers] call TC2_fnc_casCompare;
if (_results isEqualTo []) exitWith {};

private _allOk = count (_results select {!(_x select 2)}) == 0;
private _newState = if (_allOk) then {"READBACK_OK"} else {"READBACK_FAIL"};

_request set [7, _newState];
_request set [8, _results];

diag_log format ["[TC2][CAS] GERI OKUMA id=%1 | %2 | pilot=%3 | yanlislar=%4", _id, _newState, _request select 13, (_results select {!(_x select 2)}) apply {_x select 0}];

[_request select 2, "TC2_fnc_casOnResult", [_id, _newState, _results]] call TC2_fnc_netToUnit;
if (!(_request select 14) && {!isNull (_request select 4)}) then {
    [_request select 4, "TC2_fnc_casOnResult", [_id, _newState, _results]] call TC2_fnc_netToUnit;
};
