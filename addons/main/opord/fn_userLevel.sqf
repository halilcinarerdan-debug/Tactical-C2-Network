/*
    Fonksiyon: TC2_fnc_userLevel
    Çalışma yeri: Her makine (saf fonksiyon). Yetki kararı SUNUCUDA bununla verilir.

    Askerin belge yetki seviyesi (1-3):
      Level 1  herkes (varsayılan)
      Level 2  grup lideri, JTAC / gözlemci / FDC rolü, ya da rütbe >= TC2_level_rank2
      Level 3  rütbe >= TC2_level_rank3 (komuta / kurmay)
    AÇIK ATAMA: objedeki `TC2_level` (sayı 1-3; Eden init ya da Zeus Debug) rütbeyi/rolü geçersiz kılar.

    Parametreler:
        0: asker <OBJECT>

    Dönüş: seviye <NUMBER> (1-3)
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {1};

private _explicit = _unit getVariable ["TC2_level", objNull];
if (_explicit isEqualType 0) exitWith {((round _explicit) max 1) min 3};

private _rank = rankId _unit;
private _level = 1;

if (
    _rank >= (missionNamespace getVariable ["TC2_level_rank2", 2])
    || {(leader (group _unit)) isEqualTo _unit}
    || {[_unit, "JTAC"] call TC2_fnc_hasRole}
    || {[_unit, "OBSERVER"] call TC2_fnc_hasRole}
    || {[_unit, "FDC"] call TC2_fnc_hasRole}
) then {_level = 2};

if (_rank >= (missionNamespace getVariable ["TC2_level_rank3", 3])) then {_level = 3};

_level
