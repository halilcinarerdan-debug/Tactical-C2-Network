/*
    Fonksiyon: TC2_fnc_medOnIncoming
    Çalışma yeri: İSTEMCİ MÜRETTEBAT (sunucu, MEDEVAC talebini helikopter mürettebatına yollar)

    Talebi yerel önbelleğe alır (en çok 4), bip + bildirim verir. Pencere KENDİLİĞİNDEN AÇILMAZ (uçuşu bölmez); mürettebat ACE self menüsünden
    "TC2 MEDEVAC" ile okur / kabul eder. Güvenlik "E" (düşman var) ise bildirim uyarı ekler.

    Parametreler:
        0: talep id <NUMBER>   1: çağrı adı <STRING>   2: satırlar <ARRAY>   3: güvenlik kodu <STRING>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_id", -1, [0]], ["_callsign", "", [""]], ["_lines", [], [[]]], ["_security", "N", [""]]];

private _incoming = (missionNamespace getVariable ["TC2_med_incoming", []]) select {!((_x select 0) == _id)};
_incoming pushBack [_id, _callsign, _lines, "OPEN", ""];
while {count _incoming > 4} do {_incoming deleteAt 0};
missionNamespace setVariable ["TC2_med_incoming", _incoming];

if (isClass (configFile >> "CfgSounds" >> "FD_Timer_F")) then {playSound "FD_Timer_F"};

[format ["MEDEVAC TALEBİ #%1 (%2)%3", _id, _callsign, if (_security isEqualTo "E") then {"  - DÜŞMAN VAR"} else {""}], ["info", "error"] select (_security isEqualTo "E")] call TC2_fnc_notify;
