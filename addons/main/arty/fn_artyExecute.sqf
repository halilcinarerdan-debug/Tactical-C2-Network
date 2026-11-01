/*
    Fonksiyon: TC2_fnc_artyExecute
    Çalışma yeri: SADECE SUNUCU

    Görevin atışını uygular. Faz ADJUST ise tek top tek mermi (doktrin: adjust'ta normalde bir top), FFE ise atanmış tüm toplar
    hacim kadar (top başına) atar.
      - Oyuncu mürettebatlı top: oyunculara ATEŞ EMRİ bildirimi (hedef grid, azimut mil, mesafe, mühimmat, mermi sayısı) gider;
        FDC SHOT / SPLASH / ROUNDS COMPLETE'i elle girer. AI topçu YOKTUR (kaldırıldı).
      - TEST (TC2_arty_simCrew): oyuncu mürettebat yokmuş gibi emir yalnızca olay günlüğüne düşer; FDC her şeyi elle girer.

    Parametreler:
        0: görev id <NUMBER>

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_id", -1, [0]]];

private _index = [_id] call TC2_fnc_artyMissionIndex;
if (_index < 0) exitWith {};

private _mission = (missionNamespace getVariable ["TC2_arty_missions", []]) select _index;

private _guns = ((_mission select 12) apply {objectFromNetId _x}) select {!isNull _x && {alive _x}};
if (_guns isEqualTo []) exitWith {
    [_id, "Atanan top yok ya da etkisiz; görev durduruldu.", "BAD"] call TC2_fnc_artyEvent;
    _mission set [7, "SPOTTING"];
};

private _aim = _mission select 10;
private _magazine = _mission select 25;
private _adjusting = (_mission select 19) isEqualTo "ADJUST";
private _perGun = if (_adjusting) then {1} else {_mission select 13};
private _active = if (_adjusting) then {[_guns select 0]} else {_guns};
_mission set [7, "FIRING"];
_mission set [18, 0];

private _manual = false;
private _grid = [_aim] call TC2_fnc_casGrid;

{
    private _gun = _x;
    private _players = (crew _gun) select {isPlayer _x};

    if (!(_players isEqualTo []) || {_gun getVariable ["TC2_arty_simCrew", false]}) then {
        _manual = true;
        private _order = format [
            "ATEŞ EMRİ #%1: %2 x %3 mermi (%4) | hedef GRID %5 | azimut %6 mil | mesafe %7 m",
            _id, _mission select 23, _perGun, _magazine, _grid, round ([_gun getDir _aim, "TOMIL"] call TC2_fnc_artyMilsToDeg), round (_gun distance _aim)
        ];
        {[_x, "TC2_fnc_artyOnGunOrder", [_order]] call TC2_fnc_netToUnit} forEach _players;
        if (_players isEqualTo []) then {[_id, _order, "INFO", "FDC"] call TC2_fnc_artyEvent};
    };
} forEach _active;

_mission set [20, 0];
_mission set [21, _manual];

// Oyuncu mürettebatlı top yoksa görev takılı kalmasın.
if (!_manual) exitWith {
    _mission set [7, "SPOTTING"];
    [_id, "Atış yapılamadı: oyuncu mürettebatlı top yok (AI topçu desteklenmez). FDC başka batarya seçmeli.", "BAD"] call TC2_fnc_artyEvent;
};

[_id, format ["%1 mermi/top; faz %2; hedef GRID %3.", _perGun, _mission select 19, _grid], "INFO", "FDC"] call TC2_fnc_artyEvent;
[_id, "Ateş emri gitti. FDC, SHOT / SPLASH / ROUNDS COMPLETE'i elle bildirir.", "INFO", "FDC"] call TC2_fnc_artyEvent;
