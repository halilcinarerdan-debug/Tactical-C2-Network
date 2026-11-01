/*
    Fonksiyon: TC2_fnc_artyExecute
    Çalışma yeri: SADECE SUNUCU

    Görevin atışını uygular. Faz ADJUST ise tek top tek mermi (doktrin: adjust'ta normalde bir top), FFE ise atanmış tüm toplar
    hacim kadar (top başına) atar.
      - AI mürettebatlı top: CBA ayarı o taraf için açıksa `commandArtilleryFire` ile atar (top bu makinede yerel olmalı; AI mürettebat
        normalde sunucuda yereldir). Fired olayı SHOT / SPLASH / ROUNDS COMPLETE'i üretir.
      - Oyuncu mürettebatlı top: oyunculara ATEŞ EMRİ bildirimi (hedef grid, azimut mil, mesafe, mühimmat, mermi sayısı) gider;
        FDC SHOT / SPLASH / ROUNDS COMPLETE'i elle girer.
    Yedek: beklenen süre dolunca görev kendiliğinden tamamlanır.

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
private _side = side (group (_mission select 2));
private _aiAllowed = switch (_side) do {
    case west:        {missionNamespace getVariable ["TC2_arty_aiWest", true]};
    case east:        {missionNamespace getVariable ["TC2_arty_aiEast", true]};
    case independent: {missionNamespace getVariable ["TC2_arty_aiGuer", true]};
    default {false};
};

_mission set [7, "FIRING"];
_mission set [18, 0];

private _expected = 0;
private _manual = false;
private _grid = [_aim] call TC2_fnc_casGrid;

{
    private _gun = _x;
    private _players = (crew _gun) select {isPlayer _x};

    if (!(_players isEqualTo [])) then {
        _manual = true;
        private _order = format [
            "ATEŞ EMRİ #%1: %2 x %3 mermi (%4) | hedef GRID %5 | azimut %6 mil | mesafe %7 m",
            _id, _mission select 23, _perGun, _magazine, _grid, round ([_gun getDir _aim, "TOMIL"] call TC2_fnc_artyMilsToDeg), round (_gun distance _aim)
        ];
        {[_x, "TC2_fnc_artyOnGunOrder", [_order]] call TC2_fnc_netToUnit} forEach _players;
    } else {
        if (!_aiAllowed) then {
            [_id, "AI mürettebatlı top kullanımı bu taraf için CBA ayarında KAPALI.", "BAD"] call TC2_fnc_artyEvent;
        } else {
            if (!local _gun) then {
                [_id, "Top bu makinede yerel değil (AI mürettebat sunucuda olmalı); atılamadı.", "BAD"] call TC2_fnc_artyEvent;
            } else {
                if !(_gun getVariable ["TC2_arty_ehAdded", false]) then {
                    _gun setVariable ["TC2_arty_ehAdded", true];
                    _gun addEventHandler ["Fired", {params ["_gun"]; [_gun] call TC2_fnc_artyGunFired}];
                };
                _gun setVariable ["TC2_arty_mission", _id];
                _gun setVariable ["TC2_arty_mag", _magazine];
                _gun commandArtilleryFire [ASLToAGL _aim, _magazine, _perGun];
                _expected = _expected + _perGun;
            };
        };
    };
} forEach _active;

_mission set [20, _expected];
_mission set [21, _manual];

// Hiçbir top atamadıysa (AI kapalı / yerel değil) görev takılı kalmasın.
if (_expected == 0 && {!_manual}) exitWith {
    _mission set [7, "SPOTTING"];
    [_id, "Atış yapılamadı: kullanılabilir top yok. FDC başka batarya seçmeli.", "BAD"] call TC2_fnc_artyEvent;
};

[_id, format ["%1 mermi/top; faz %2; hedef GRID %3.", _perGun, _mission select 19, _grid], "INFO", "FDC"] call TC2_fnc_artyEvent;

if (_manual) then {
    [_id, "Oyuncu bataryası: ateş emri gitti. FDC, SHOT / SPLASH / ROUNDS COMPLETE'i elle bildirir.", "INFO", "FDC"] call TC2_fnc_artyEvent;
};

// Yedek tamamlanma: otomatik atış beklenenden uzun sürerse görevi kapat.
if (_expected > 0) then {
    [{
        params ["_id"];
        private _index = [_id] call TC2_fnc_artyMissionIndex;
        if (_index < 0) exitWith {};
        if (((missionNamespace getVariable ["TC2_arty_missions", []]) select _index) select 7 isEqualTo "FIRING") then {
            [_id, "DONE"] call TC2_fnc_artyComplete;
        };
    }, [_id], 120 + _expected * 12] call CBA_fnc_waitAndExecute;
};
