/*
    Fonksiyon: TC2_fnc_casOnIncoming
    Çalışma yeri: İSTEMCİ PİLOT (sunucu, 9-Line gönderilince alıcıya yollar)

    Gelen 9-Line'ı saklar, kısa bir bip + bildirim verir. Pencere KENDİLİĞİNDEN AÇILMAZ (uçuşu bölmez);
    pilot ACE self menüsünden "CAS 9-Line" ile açar.

    Parametreler:
        0: talep id <NUMBER>
        1: JTAC çağrı adı <STRING>
        2: pilot çağrı adı <STRING>
        3: form verisi <ARRAY>
        4: platform <STRING>
        5: durum <STRING>
        6: geri okuma sonuçları <ARRAY>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_id", -1, [0]], ["_jtac", "", [""]], ["_pilot", "", [""]], ["_data", [], [[]]], ["_platform", "FW", [""]], ["_state", "SENT", [""]], ["_results", [], [[]]]];

missionNamespace setVariable ["TC2_cas_incoming", [_id, _jtac, _pilot, _data, _platform, _state, _results]];

if (isClass (configFile >> "CfgSounds" >> "FD_Timer_F")) then {playSound "FD_Timer_F"};

[format ["CAS 9-LINE ALINDI: %1  |  ACE self menü > CAS 9-Line", _jtac], "info"] call TC2_fnc_notify;

call TC2_fnc_casPilotUpdate;
