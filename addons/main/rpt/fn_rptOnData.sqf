/*
    Fonksiyon: TC2_fnc_rptOnData
    Çalışma yeri: İSTEMCİ (sunucu rptPoll'e yanıt olarak gönderir)

    Rapor listesini saklar ve RAPOR sekmesini günceller.

    Parametreler:
        0: kod <STRING>  "OK" | erişim ret nedeni
        1: seviye <NUMBER>
        2: yazabilir mi <BOOL>
        3: doğrulayabilir mi <BOOL>  (S2 / CO)
        4: raporlar <ARRAY>  [[id, tür, çağrı adı, yaş sn, doğrulandı mı, satırlar [[etiket, değer]]]]

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_level", 1, [0]], ["_canWrite", false, [false]], ["_canVerify", false, [false]], ["_reports", [], [[]]]];

missionNamespace setVariable ["TC2_rpt_data", [_code, _level, _canWrite, _canVerify, _reports]];

call TC2_fnc_rptUiUpdate;
