/*
    Fonksiyon: TC2_fnc_casOnData
    Çalışma yeri: İSTEMCİ (sunucu casPoll'e yanıt olarak gönderir)

    CAS sekmesi verisi: [JTAC mi, alıcılar, etkin talep özeti]. Özet: [id, durum, pilot adı, geri okuma sonuçları, form verisi, platform].

    Parametreler:
        0: kod <STRING>
        1: JTAC mi <BOOL>
        2: alıcılar <ARRAY>  [[netId, etiket, platform, mesafe, simüle]]
        3: talep özeti <ARRAY>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_isJtac", false, [false]], ["_targets", [], [[]]], ["_summary", [], [[]]]];

missionNamespace setVariable ["TC2_cas_data", [_isJtac, _targets, _summary]];

if !(_code isEqualTo "OK") then {
    missionNamespace setVariable ["TC2_cas_statusText", format ["BAĞLANTI YOK  |  %1", [_code] call TC2_fnc_accessReasonText]];
};

call TC2_fnc_casUiUpdate;
