/*
    Fonksiyon: TC2_fnc_artyComplete
    Çalışma yeri: SADECE SUNUCU

    Atışı bitirir ve görevi bir sonraki duruma geçirir:
      DONE  : "ROUNDS COMPLETE". Adjust fazındaysa SPOTTING (gözlemci düzeltme gönderir), aksi halde SURVEILLANCE (gözlemci gözetim + END OF MISSION).
      CHECK : "CHECK FIRING" (acil durdurma, ATP 3-09.30, 4-57): atış durdurulur (oyuncu mürettebata durdurma bildirimi olay günlüğündedir).
    Toplardaki görev işaretleri temizlenir.

    Parametreler:
        0: görev id <NUMBER>
        1: neden <STRING>  "DONE" (varsayılan) | "CHECK"

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_id", -1, [0]], ["_reason", "DONE", [""]]];

private _index = [_id] call TC2_fnc_artyMissionIndex;
if (_index < 0) exitWith {};

private _mission = (missionNamespace getVariable ["TC2_arty_missions", []]) select _index;
if !((_mission select 7) in ["FIRING", "READY"]) exitWith {};

{
    private _gun = objectFromNetId _x;
    if (!isNull _gun) then {
        _gun setVariable ["TC2_arty_mission", -1];
    };
} forEach (_mission select 12);

private _next = ["SURVEILLANCE", "SPOTTING"] select ((_mission select 19) isEqualTo "ADJUST");
_mission set [7, _next];

if (_reason isEqualTo "CHECK") then {
    [_id, "CHECK FIRING. Atış durduruldu.", "BAD"] call TC2_fnc_artyEvent;
} else {
    [_id, "ROUNDS COMPLETE, OUT.", "GOOD"] call TC2_fnc_artyEvent;
    [_id, ["Gözlemci: düzeltme gönder (LEFT/RIGHT, ADD/DROP) ya da FIRE FOR EFFECT.", "Gözlemci: gözetim yap ve END OF MISSION ya da REPEAT gönder."] select (_next isEqualTo "SURVEILLANCE"), "INFO", "OBS"] call TC2_fnc_artyEvent;
};
