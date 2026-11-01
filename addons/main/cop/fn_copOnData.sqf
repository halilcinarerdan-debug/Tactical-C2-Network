/*
    Fonksiyon: TC2_fnc_copOnData
    Çalışma yeri: İSTEMCİ (sunucu copRequest'e yanıt olarak gönderir)

    Harita verisini saklar; çizim copUiDraw'da yapılır. Önbellek: [dostlar, işaretler].

    Parametreler:
        0: kod <STRING>  "OK" | "NO_RADIO" | "NO_ACRE" | erişim ret nedeni
        1: dostlar <ARRAY>   [[konum ASL, etiket, lider mi]]
        2: işaretler <ARRAY> [[id, tür, konum ASL, koyan, yaş sn]]

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_friends", [], [[]]], ["_markers", [], [[]]]];

missionNamespace setVariable ["TC2_cop_data", [_friends, _markers]];

if ((missionNamespace getVariable ["TC2_cop_mode", ""]) isEqualTo "") then {
    if (_code isEqualTo "OK") then {
        [format ["  %1 dost   |   %2 düşman işareti", count _friends, count _markers], [0.25, 1, 0.35, 1]] call TC2_fnc_copUiStatus;
    } else {
        [format ["  BAĞLANTI YOK   |   %1", [_code] call TC2_fnc_accessReasonText], [1, 0.35, 0.35, 1]] call TC2_fnc_copUiStatus;
    };
};
