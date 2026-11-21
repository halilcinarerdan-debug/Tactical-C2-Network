/*
    Fonksiyon: TC2_fnc_opordLoad
    Çalışma yeri: SADECE SUNUCU (XEH_postInit)

    Mission klasöründe varsa okur ve yayımlar:
        tc2_opord.sqf         -> OPORD, ÜÇ TARAFA DA aynı (ortak)
        tc2_opord_west.sqf    -> yalnızca BLUFOR'un OPORD'u   (tc2_opord_east.sqf OPFOR, tc2_opord_guer.sqf INDFOR)
        tc2_warno.sqf, tc2_warno_west.sqf, ...  -> aynı mantıkla WARNO (uyarı emri)
    TARAF AYRIMI: tarafa özel dosya, ortak dosyayı o taraf için geçersiz kılar (ortak dosya önce yüklenir).
    Dosya şu diziyi döndürmelidir:
        [başlık, DTG, gizlilik etiketi, [[anahtar, başlık, seviye, metin], ...], yayımlayan (isteğe bağlı)]
    Örnek: docs/ornek_tc2_opord.sqf

    Parametreler: yok
    Dönüş: yok
*/

if (!isServer) exitWith {};

{
    _x params ["_file", "_docType", "_side"];

    if (fileExists _file) then {
        private _data = call compile preprocessFileLineNumbers _file;

        if !(_data isEqualType [] && {count _data >= 4}) then {
            diag_log format ["[TC2][OPORD] %1 gecersiz: [baslik, dtg, etiket, [bolumler]] dizisi bekleniyor.", _file];
        } else {
            _data params ["_title", "_dtg", "_classification", "_sections", ["_issuer", "", [""]]];
            [_title, _dtg, _classification, _sections, _issuer, _docType, _side] call TC2_fnc_opordSet;
        };
    };
} forEach [
    ["tc2_opord.sqf", "OPORD", "ALL"], ["tc2_warno.sqf", "WARNO", "ALL"],
    ["tc2_opord_west.sqf", "OPORD", west], ["tc2_opord_east.sqf", "OPORD", east], ["tc2_opord_guer.sqf", "OPORD", independent],
    ["tc2_warno_west.sqf", "WARNO", west], ["tc2_warno_east.sqf", "WARNO", east], ["tc2_warno_guer.sqf", "WARNO", independent]
];
