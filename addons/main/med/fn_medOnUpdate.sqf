/*
    Fonksiyon: TC2_fnc_medOnUpdate
    Çalışma yeri: İSTEMCİ (sunucu, talebin durumu değişince talep sahibine ve alıcı mürettebata yollar)

    Parametreler:
        0: talep id <NUMBER>
        1: durum <STRING>  "ACCEPTED" (talep sahibi için) | "TAKEN" (diğer mürettebat için: başkası kabul etti) | "CANCELLED"
        2: kabul eden çağrı adı <STRING>   3: tahmini varış dk <NUMBER>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_id", -1, [0]], ["_status", "", [""]], ["_callsign", "", [""]], ["_eta", 0, [0]]];

// Mürettebat önbelleğini güncelle
private _incoming = missionNamespace getVariable ["TC2_med_incoming", []];
{
    if ((_x select 0) == _id) then {
        _x set [3, switch (_status) do {case "ACCEPTED": {"ACCEPTED"}; case "TAKEN": {"TAKEN"}; default {"CANCELLED"}}];
        _x set [4, _callsign];
    };
} forEach _incoming;
// iptal / başkası aldı ise listeden düşür
missionNamespace setVariable ["TC2_med_incoming", _incoming select {!((_x select 0) == _id && {(_x select 3) in ["CANCELLED", "TAKEN"]})}];

switch (_status) do {
    case "ACCEPTED": {
        if (isClass (configFile >> "CfgSounds" >> "FD_Timer_F")) then {playSound "FD_Timer_F"};
        [format ["MEDEVAC #%1 KABUL: %2, tahmini varış %3 dk", _id, _callsign, _eta], "success"] call TC2_fnc_notify;
    };
    case "TAKEN":     {[format ["MEDEVAC #%1 başka mürettebat tarafından alındı (%2).", _id, _callsign], "info"] call TC2_fnc_notify};
    case "CANCELLED": {[format ["MEDEVAC #%1 İPTAL edildi.", _id], "info"] call TC2_fnc_notify};
};

call TC2_fnc_medUiRequest;
