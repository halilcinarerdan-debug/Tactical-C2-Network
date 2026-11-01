/*
    Fonksiyon: TC2_fnc_artyBatteries
    Çalışma yeri: SADECE SUNUCU (saf)

    Bir tarafın kullanılabilir topçu bataryalarını verir. Topçu araçları OTOMATİK bulunur (artyIsGun); aynı mürettebat grubunu
    paylaşan toplar tek BATARYA sayılır, mürettebatsız bir araç kendi başına bir bataryadır.
    Mürettebat türü (AI topçu YOK; yalnızca oyuncu mürettebatlı bataryalar kullanılır):
      PLAYER -> en az bir oyuncu mürettebatı var (emirler oyunculara bildirilir; FDC SHOT/SPLASH/COMPLETE'i elle girer)
      SIM    -> TEST: topta TC2_arty_simCrew = true (debugArtyCrew); oyuncu yokmuş gibi emir alır, FDC her şeyi elle girer
      AI     -> AI mürettebat: KULLANILAMAZ
      EMPTY  -> mürettebat yok: KULLANILAMAZ

    Parametreler:
        0: taraf <SIDE>

    Dönüş: [[anahtar, etiket, mürettebat türü, [araç netId'leri], kullanılabilir mi]] <ARRAY>
*/

params [["_side", west, [west]]];

private _batteries = [];

{
    private _vehicle = _x;
    if (alive _vehicle && {[_vehicle] call TC2_fnc_artyIsGun}) then {
        private _config = configFile >> "CfgVehicles" >> typeOf _vehicle;
        private _crewed = !((crew _vehicle) isEqualTo []);
        private _vehicleSide = if (_crewed) then {side (group (effectiveCommander _vehicle))} else {[east, west, independent, civilian] select ((getNumber (_config >> "side")) max 0 min 3)};

        if (_vehicleSide isEqualTo _side) then {
            private _key = if (_crewed) then {netId (group (effectiveCommander _vehicle))} else {netId _vehicle};
            private _label = if (_crewed) then {
                format ["%1 (%2)", groupId (group (effectiveCommander _vehicle)), getText (_config >> "displayName")]
            } else {
                format ["%1 (mürettebatsız)", getText (_config >> "displayName")]
            };
            private _crewType = if (_vehicle getVariable ["TC2_arty_simCrew", false]) then {"SIM"} else {
                if (!_crewed) then {"EMPTY"} else {["AI", "PLAYER"] select (count ((crew _vehicle) select {isPlayer _x}) > 0)}
            };

            private _index = -1;
            {
                if ((_x select 0) isEqualTo _key) exitWith {_index = _forEachIndex};
            } forEach _batteries;

            if (_index < 0) then {
                _batteries pushBack [_key, [_label, 40] call TC2_fnc_netSanitize, _crewType, [netId _vehicle], true];
            } else {
                ((_batteries select _index) select 3) pushBack (netId _vehicle);
                // karışık mürettebat: oyuncu varsa PLAYER sayılır
                if (_crewType in ["PLAYER", "SIM"]) then {(_batteries select _index) set [2, _crewType]};
            };
        };
    };
} forEach vehicles;

// AI topçu yok: yalnızca oyuncu (ya da TEST için SIM) mürettebatlı bataryalar kullanılabilir.
{
    _x set [4, (_x select 2) in ["PLAYER", "SIM"]];
} forEach _batteries;

_batteries
