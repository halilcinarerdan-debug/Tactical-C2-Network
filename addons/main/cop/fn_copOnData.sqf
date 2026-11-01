/*
    Fonksiyon: TC2_fnc_copOnData
    Çalışma yeri: İSTEMCİ (sunucu copRequest'e yanıt olarak gönderir)

    Harita verisini saklar; çizim copUiDraw'da yapılır. Önbellek: [dostlar, işaretler, doğrulanmamış SALUTE].

    Parametreler:
        0: kod <STRING>  "OK" | "NO_RADIO" | "NO_ACRE" | erişim ret nedeni
        1: dostlar <ARRAY>   [[konum ASL, etiket, lider mi, lace, bakış yönü]]  (önbelleğe lace özet durumu eklenir)
        2: işaretler <ARRAY> [[id, tür, konum ASL, koyan, yaş sn]]
        3: doğrulanmamış SALUTE <ARRAY> [[rapor id, konum ASL, yaş sn, çağrı adı]]  (Level 2+)

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_friends", [], [[]]], ["_markers", [], [[]]], ["_unverified", [], [[]]]];

// Dostlara LACE özet durumu eklenir (5. öğe); çizim her karede yeniden hesaplamasın diye burada bir kez.
_friends = _friends apply {
    _x params ["_pos", "_label", "_leader", ["_lace", []], ["_heading", -1]];
    [_pos, _label, _leader, _lace, [_lace] call TC2_fnc_rptLaceStatus, _heading]
};

missionNamespace setVariable ["TC2_cop_data", [_friends, _markers, _unverified]];

// Oyun işaretleri yalnızca harita görünürken hazırlanır (diğer sekmeler de copRequest çağırır).
if ((missionNamespace getVariable ["TC2_ui_tab", 0]) == 1) then {call TC2_fnc_copGameMarkers};

if ((missionNamespace getVariable ["TC2_cop_mode", ""]) isEqualTo "") then {
    if (_code isEqualTo "OK") then {
        [format ["  %1 dost   |   %2 düşman işareti", count _friends, count _markers], [0.25, 1, 0.35, 1]] call TC2_fnc_copUiStatus;
    } else {
        [format ["  BAĞLANTI YOK   |   %1", [_code] call TC2_fnc_accessReasonText], [1, 0.35, 0.35, 1]] call TC2_fnc_copUiStatus;
    };
};
