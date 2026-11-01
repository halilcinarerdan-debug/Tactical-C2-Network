/*
    Fonksiyon: TC2_fnc_opordSet
    Çalışma yeri: SADECE SUNUCU (mission scripti / Zeus "Execute Code" (sunucu) / opordLoad)

    OPORD belgesini topluca tanımlar (var olanın yerine geçer, sürüm 1'den başlar). Mission yapımcısının ana yolu:
    mission klasöründeki `tc2_opord.sqf` dosyası (opordLoad okur), ya da bu fonksiyon.

    Bölüm biçimi: [anahtar <STRING>, başlık <STRING>, seviye <NUMBER 1-3>, metin <STRING>]. Metin düz metindir, satır sonu = toString [10].

    Parametreler:
        0: başlık <STRING>        örn. "OPERASYON EMRİ 01-26"
        1: DTG / tarih <STRING>   örn. "011800ZNOV26"
        2: gizlilik etiketi <STRING>  örn. "TC2 EGITIM - DAGITIM SINIRLI"
        3: bölümler <ARRAY>
        4: yayımlayan <STRING>    (isteğe bağlı)

    Dönüş: başarılı mı <BOOL>
*/

if (!isServer) exitWith {false};

params [["_title", "", [""]], ["_dtg", "", [""]], ["_classification", "", [""]], ["_sections", [], [[]]], ["_issuer", "", [""]]];

private _clean = (_sections select {
    count _x == 4 && {(_x select 0) isEqualType ""} && {(_x select 1) isEqualType ""} && {(_x select 2) isEqualType 0} && {(_x select 3) isEqualType ""}
}) apply {
    [_x select 0, _x select 1, (round (_x select 2)) max 1 min 3, _x select 3]
};

if (_clean isEqualTo []) exitWith {
    diag_log "[TC2][OPORD] opordSet: gecerli bolum yok.";
    false
};

missionNamespace setVariable ["TC2_opord", [_title, _dtg, _classification, 1, _issuer, _clean, []]];
diag_log format ["[TC2][OPORD] yayimlandi '%1' | %2 bolum | yayimlayan=%3", _title, count _clean, _issuer];

true
