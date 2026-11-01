/*
    Fonksiyon: TC2_fnc_opordLoad
    Çalışma yeri: SADECE SUNUCU (XEH_postInit)

    Mission klasöründe `tc2_opord.sqf` varsa okur ve OPORD'u yayımlar. Dosya şu diziyi döndürmelidir:
        [başlık, DTG, gizlilik etiketi, [[anahtar, başlık, seviye, metin], ...], yayımlayan (isteğe bağlı)]
    Örnek: docs/ornek_tc2_opord.sqf

    Parametreler: yok
    Dönüş: yok
*/

if (!isServer) exitWith {};

private _file = "tc2_opord.sqf";
if (!fileExists _file) exitWith {};

private _data = call compile preprocessFileLineNumbers _file;

if !(_data isEqualType [] && {count _data >= 4}) exitWith {
    diag_log "[TC2][OPORD] tc2_opord.sqf gecersiz: [baslik, dtg, etiket, [bolumler]] dizisi bekleniyor.";
};

_data params ["_title", "_dtg", "_classification", "_sections", ["_issuer", "", [""]]];
[_title, _dtg, _classification, _sections, _issuer] call TC2_fnc_opordSet;
