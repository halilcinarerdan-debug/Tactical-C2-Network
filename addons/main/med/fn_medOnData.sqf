/*
    Fonksiyon: TC2_fnc_medOnData
    Çalışma yeri: İSTEMCİ (sunucu medPoll'e yanıt olarak gönderir)

    Parametreler:
        0: kod <STRING>  "OK" | erişim ret nedeni
        1: seviye <NUMBER>
        2: yazabilir mi <BOOL>
        3: talepler <ARRAY>  [[id, çağrı adı, yaş sn, durum, kabul eden, ETA dk, benim mi, satırlar [[etiket, değer]]]]

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_level", 1, [0]], ["_canWrite", false, [false]], ["_requests", [], [[]]]];

missionNamespace setVariable ["TC2_med_data", [_code, _level, _canWrite, _requests]];

call TC2_fnc_medUiUpdate;
