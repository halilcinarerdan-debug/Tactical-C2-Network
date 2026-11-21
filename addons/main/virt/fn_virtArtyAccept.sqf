/*
    Fonksiyon: TC2_fnc_virtArtyAccept
    Çalışma yeri: SADECE SUNUCU

    SANAL bataryayla CFF KABUL: FDC (oyuncu ya da sanal FDC) görevi kabul eder. Hedef numarası verilir, MTO yayımlanır, görev alanları doldurulur;
    AT MY COMMAND ise "IS READY", değilse atış başlar (virtArtyFire, artyExecute üzerinden). Mühimmat türü (HE / SMOKE / WP / ILLUM) CBA kalibresine
    göre bir mermi sınıfına çevrilir; yoksa görev REDDEDİLİR.

    Parametreler:
        0: görev id <NUMBER>
        1: istenen mermi (top başına; 0 = CFF'tekini koru) <NUMBER>
        2: değişiklikler <STRING>
        3: FDC adı <STRING>  (günlük için)

    Dönüş: hedef numarası <STRING> ("" = kabul edilemedi; nedeni olay günlüğüne yazılır)
*/

if (!isServer) exitWith {""};

params [["_id", -1, [0]], ["_volume", 0, [0]], ["_changes", "", [""]], ["_fdcName", "SANAL FDC", [""]]];

private _index = [_id] call TC2_fnc_artyMissionIndex;
if (_index < 0) exitWith {""};

private _mission = (missionNamespace getVariable ["TC2_arty_missions", []]) select _index;
if !((_mission select 7) isEqualTo "REQUEST") exitWith {""};

private _data = _mission select 8;
private _shell = [_data select 11] call TC2_fnc_virtShellClass;
if (_shell isEqualTo "") exitWith {
    _mission set [7, "REJECTED"];
    [_id, format ["CFF REDDEDİLDİ: sanal bataryada %1 mühimmatı yok.", _data select 11], "BAD"] call TC2_fnc_artyEvent;
    ""
};

private _targetCounter = (missionNamespace getVariable ["TC2_arty_targetCounter", 0]) + 1;
missionNamespace setVariable ["TC2_arty_targetCounter", _targetCounter];
private _targetNo = format ["AF%1", 1000 + _targetCounter];

private _rounds = if (_volume >= 1) then {_volume min 10} else {_mission select 13};
private _changesText = [_changes, 60] call TC2_fnc_netSanitize;
private _label = format ["SANAL BATARYA (%1 mm)", missionNamespace getVariable ["TC2_virt_artyCaliber", "155"]];

_mission set [9, _targetNo];
_mission set [12, []];
_mission set [13, _rounds];
_mission set [23, _label];
_mission set [24, _changesText];
_mission set [25, "VIRT:" + _shell];

[_id, format [
    "MTO, %1, %2, %3 ROUNDS, TARGET %4, BREAK, DIRECTION %5, OVER.",
    _label, ["CFF AYNEN", _changesText] select !(_changesText isEqualTo ""), _rounds, _targetNo, _mission select 11
], "GOOD"] call TC2_fnc_artyEvent;

diag_log format ["[TC2][TOPCU] SANAL KABUL id=%1 | fdc=%2 | hedef=%3 | mermi=%4 | sinif=%5", _id, _fdcName, _targetNo, _rounds, _shell];

if ((_data select 13) isEqualTo "AMC") then {
    _mission set [7, "READY"];
    [_id, format ["%1 IS READY, OVER.", _label], "GOOD"] call TC2_fnc_artyEvent;
} else {
    [_id] call TC2_fnc_artyExecute;
};

_targetNo
