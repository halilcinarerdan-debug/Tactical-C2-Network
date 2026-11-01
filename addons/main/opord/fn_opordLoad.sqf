/*
    Fonksiyon: TC2_fnc_opordLoad
    Çalışma yeri: SADECE SUNUCU (XEH_postInit)

    Mission klasöründe varsa okur ve yayımlar:
        tc2_opord.sqf  -> OPORD (operasyon emri)
        tc2_warno.sqf  -> WARNO (uyarı emri)
    Dosya şu diziyi döndürmelidir:
        [başlık, DTG, gizlilik etiketi, [[anahtar, başlık, seviye, metin], ...], yayımlayan (isteğe bağlı)]
    Örnek: docs/ornek_tc2_opord.sqf

    Parametreler: yok
    Dönüş: yok
*/

if (!isServer) exitWith {};

{
    _x params ["_file", "_docType"];

    if (fileExists _file) then {
        private _data = call compile preprocessFileLineNumbers _file;

        if !(_data isEqualType [] && {count _data >= 4}) then {
            diag_log format ["[TC2][OPORD] %1 gecersiz: [baslik, dtg, etiket, [bolumler]] dizisi bekleniyor.", _file];
        } else {
            _data params ["_title", "_dtg", "_classification", "_sections", ["_issuer", "", [""]]];
            [_title, _dtg, _classification, _sections, _issuer, _docType] call TC2_fnc_opordSet;
        };
    };
} forEach [["tc2_opord.sqf", "OPORD"], ["tc2_warno.sqf", "WARNO"]];
