/*
    Fonksiyon: TC2_fnc_artyGunFired
    Çalışma yeri: SADECE SUNUCU (topun "Fired" olayı; yalnızca TC2 görevi için ateş eden toplar)

    Atılan mermiyi sayar:
      - ilk mermi  -> FDC komutu SHOT (adjust'ta her mermi, FFE'de ilk mermi; ATP 3-09.30, 4-80),
      - yüksek açı ya da hava gözlemcisi varsa SPLASH, uçuş süresinden 5 sn önce (4-81),
      - beklenen sayıya ulaşınca -> ROUNDS COMPLETE (4-82) ve görev tamamlanır.

    Parametreler:
        0: top <OBJECT>

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_gun", objNull, [objNull]]];

private _id = _gun getVariable ["TC2_arty_mission", -1];
if (_id < 0) exitWith {};

private _index = [_id] call TC2_fnc_artyMissionIndex;
if (_index < 0) exitWith {};

private _mission = (missionNamespace getVariable ["TC2_arty_missions", []]) select _index;
if !((_mission select 7) isEqualTo "FIRING") exitWith {};

private _fired = (_mission select 18) + 1;
_mission set [18, _fired];

if (_fired == 1) then {
    [_id, "SHOT, OUT.", "GOOD"] call TC2_fnc_artyEvent;

    private _data = _mission select 8;
    private _aerial = (vehicle (_mission select 2)) isKindOf "Air";
    if ((_data select 10) isEqualTo "HIGH" || {_aerial}) then {
        private _eta = _gun getArtilleryETA [_mission select 10, _gun getVariable ["TC2_arty_mag", ""]];
        if (_eta > 0) then {
            [{
                params ["_id"];
                private _index = [_id] call TC2_fnc_artyMissionIndex;
                if (_index < 0) exitWith {};
                if (((missionNamespace getVariable ["TC2_arty_missions", []]) select _index) select 7 isEqualTo "FIRING") then {
                    [_id, "SPLASH, OVER.", "GOOD"] call TC2_fnc_artyEvent;
                };
            }, [_id], (_eta - 5) max 0] call CBA_fnc_waitAndExecute;
        };
    };
};

if ((_mission select 20) > 0 && {_fired >= (_mission select 20)}) then {
    [_id, "DONE"] call TC2_fnc_artyComplete;
};
