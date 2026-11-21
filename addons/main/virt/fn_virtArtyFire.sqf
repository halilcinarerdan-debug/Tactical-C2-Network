/*
    Fonksiyon: TC2_fnc_virtArtyFire
    Çalışma yeri: SADECE SUNUCU (artyExecute, görevin mermi alanı "VIRT:..." ise çağırır)

    Sanal bataryanın atışı. Zaman çizelgesi (hepsi CBA ayarlı):
      t = hazırlık                      : ilk mermi atılır, "SHOT, OUT."
      ilk mermi düşmeden 5 sn önce      : "SPLASH, OVER."
      her mermi: atış + uçuş süresi     : mermi hedefe (sapmayla) düşer
      son mermi atıldığında             : "ROUNDS COMPLETE, OUT." (artyComplete) ve görev gözlemci düzeltmesi / gözetim durumuna geçer
    Adjust fire: tek mermi. Fire for effect: istenen mermi x batarya top sayısı. CHECK FIRING ya da yeni atış, atılmamış mermileri iptal eder
    (havadaki mermiler düşer). Uçuş süresi kalibreye göre: 82 mm 18 sn, 120 mm 24 sn, 155 mm 32 sn.

    Parametreler:
        0: görev id <NUMBER>

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_id", -1, [0]]];

private _index = [_id] call TC2_fnc_artyMissionIndex;
if (_index < 0) exitWith {};

private _mission = (missionNamespace getVariable ["TC2_arty_missions", []]) select _index;

private _shell = (_mission select 25) select [5, (count (_mission select 25)) - 5];
private _aim = _mission select 10;
private _adjusting = (_mission select 19) isEqualTo "ADJUST";
private _guns = round (missionNamespace getVariable ["TC2_virt_artyGuns", 4]);
private _total = if (_adjusting) then {1} else {((_mission select 13) max 1) * (_guns max 1)};

private _prep = missionNamespace getVariable ["TC2_virt_artyPrep", 15];
private _rate = missionNamespace getVariable ["TC2_virt_artyRate", 4];
private _error = missionNamespace getVariable ["TC2_virt_artyError", 25];
private _flight = switch (missionNamespace getVariable ["TC2_virt_artyCaliber", "155"]) do {
    case "82": {18};
    case "120": {24};
    default {32};
};

private _runVar = format ["TC2_virt_run_%1", _id];
private _run = (missionNamespace getVariable [_runVar, 0]) + 1;
missionNamespace setVariable [_runVar, _run];

_mission set [7, "FIRING"];
_mission set [18, 0];
_mission set [20, 0];
_mission set [21, false];

[_id, format ["%1 mermi, %2 sn sonra atış (hazırlık).", _total, round _prep], "INFO", "FDC"] call TC2_fnc_artyEvent;

for "_k" from 0 to (_total - 1) do {
    [{
        params ["_id", "_run", "_k", "_total", "_aim", "_shell", "_error", "_flight"];

        private _index = [_id] call TC2_fnc_artyMissionIndex;
        if (_index < 0) exitWith {};
        if !((missionNamespace getVariable [format ["TC2_virt_run_%1", _id], 0]) == _run) exitWith {};

        private _mission = (missionNamespace getVariable ["TC2_arty_missions", []]) select _index;
        if !((_mission select 7) isEqualTo "FIRING") exitWith {};

        _mission set [18, (_mission select 18) + 1];

        if (_k == 0) then {
            [_id, "SHOT, OUT.", "GOOD"] call TC2_fnc_artyEvent;
            if (_flight > 6) then {
                [{
                    params ["_id", "_run"];
                    if ((missionNamespace getVariable [format ["TC2_virt_run_%1", _id], 0]) == _run) then {
                        [_id, "SPLASH, OVER.", "GOOD"] call TC2_fnc_artyEvent;
                    };
                }, [_id, _run], _flight - 5] call CBA_fnc_waitAndExecute;
            };
        };

        // mermi uçuş süresi sonra düşer (atıldıktan sonra iptal edilemez)
        [TC2_fnc_virtShell, [_aim, _shell, _error], _flight] call CBA_fnc_waitAndExecute;

        if (_k == _total - 1) then {
            [_id, "DONE"] call TC2_fnc_artyComplete;
        };
    }, [_id, _run, _k, _total, _aim, _shell, _error, _flight], _prep + _k * _rate] call CBA_fnc_waitAndExecute;
};
