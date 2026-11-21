/*
    Fonksiyon: TC2_fnc_camOnData
    Çalışma yeri: İSTEMCİ (sunucu camPoll'e yanıt olarak gönderir)

    Parametreler:
        0: kod <STRING>  "OK" | erişim ret nedeni
        1: seviye <NUMBER>
        2: izleyebilir mi <BOOL>
        3: kaynaklar <ARRAY>  [[tür "UAV" | "HELM", netId, etiket]]

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_level", 1, [0]], ["_canView", false, [false]], ["_sources", [], [[]]]];

missionNamespace setVariable ["TC2_cam_data", [_code, _level, _canView, _sources]];

call TC2_fnc_camUiUpdate;
