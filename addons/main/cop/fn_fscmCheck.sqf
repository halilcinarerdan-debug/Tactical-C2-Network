/*
    Fonksiyon: TC2_fnc_fscmCheck
    Çalışma yeri: SADECE SUNUCU (saf)

    Ateş destek koordinasyon ölçüleri (FSCM) denetimi. Alan işaretleri Eden'de / Zeus'ta / script ile oluşturulan DİKDÖRTGEN ya da ELİPS
    harita işaretleridir ve ADLARI şu önekle başlar:
        TC2_NFA...  ATEŞ YASAK ALANI (no-fire area): içindeki hedefe CAS talebi ve CFF REDDEDİLİR
        TC2_RFA...  KISITLI ATEŞ ALANI (restrictive fire area): izin verilir ama ağa UYARI düşer (onay gerekir)
    Terminal haritası bu alanları KATMAN açıkken oyun işaretleri olarak (dolgulu) gösterir; ayrı arayüz yoktur.
    Doktrin: JP 3-09 / JP 3-09.3 (NFA, RFA tanımları).

    Parametreler:
        0: konum <ARRAY>  (ASL ya da AGL; yalnızca x ve y kullanılır)

    Dönüş: [tür <STRING> "NFA" | "RFA" | "", işaret adı <STRING>]  (NFA, RFA'ya göre önceliklidir)
*/

params [["_pos", [0, 0, 0], [[]]]];

private _result = ["", ""];
private _pos2 = [_pos param [0, 0], _pos param [1, 0], 0];

{
    private _name = _x;
    if (!((markerShape _name) isEqualTo "ICON")) then {
        if (_pos2 inArea _name) then {
            if ((_name find "TC2_NFA") == 0) exitWith {_result = ["NFA", _name]};
            if ((_name find "TC2_RFA") == 0 && {(_result select 0) isEqualTo ""}) then {_result = ["RFA", _name]};
        };
    };
} forEach (allMapMarkers select {((_x find "TC2_NFA") == 0) || {(_x find "TC2_RFA") == 0}});

_result
