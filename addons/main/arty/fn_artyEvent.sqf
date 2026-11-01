/*
    Fonksiyon: TC2_fnc_artyEvent
    Çalışma yeri: SADECE SUNUCU

    Görev günlüğüne bir satır ekler (son 14) ve gözlemciye ile FDC'ye anında iletir (artyOnEvent).
    FDC komutları (SHOT, SPLASH, ROUNDS COMPLETE, ...) ve MTO satırları bununla gider.

    Parametreler:
        0: görev id <NUMBER>
        1: metin <STRING>   (temizlenmiş olmalı)
        2: ton <STRING>     "INFO" | "GOOD" | "BAD" | "BEEP"  (BEEP: FDC'ye yeni CFF; bildirim + bip)
        3: alıcılar <STRING> "BOTH" (varsayılan) | "OBS" | "FDC"

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_id", -1, [0]], ["_text", "", [""]], ["_tone", "INFO", [""]], ["_to", "BOTH", [""]]];

private _index = [_id] call TC2_fnc_artyMissionIndex;
if (_index < 0) exitWith {};

private _mission = (missionNamespace getVariable ["TC2_arty_missions", []]) select _index;
private _log = _mission select 14;
_log pushBack _text;
while {count _log > 14} do {_log deleteAt 0};

private _observer = _mission select 2;
private _fdc = _mission select 5;

if (_to in ["BOTH", "OBS"] && {!isNull _observer}) then {
    [_observer, "TC2_fnc_artyOnEvent", [_id, _text, _tone]] call TC2_fnc_netToUnit;
};
if (_to in ["BOTH", "FDC"] && {!isNull _fdc} && {!(_fdc isEqualTo _observer) || {_to isEqualTo "FDC"}}) then {
    [_fdc, "TC2_fnc_artyOnEvent", [_id, _text, _tone]] call TC2_fnc_netToUnit;
};
