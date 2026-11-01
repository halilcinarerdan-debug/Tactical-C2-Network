/*
    Fonksiyon: TC2_fnc_rptValidate
    Çalışma yeri: Her makine (saf fonksiyon). Sunucu KARAR için, istemci anında geri bildirim için çağırır.

    Saha raporu formlarını denetler. Veri, sabit uzunlukta METİN dizisidir:
      SALUTE (6):  [Size, Activity, konum anahtarı ("OWN" | "M<işaret id>"), Unit, Time (boş = şimdi), Equipment]
      SITREP (6):  [faaliyet, düşman, personel, lojistik, niyet, notlar]
      LACE   (8):  [Liquids durumu, not, Ammunition durumu, not, Casualties durumu, not, Equipment durumu, not]
                   durum: GREEN | AMBER | RED | BLACK

    DOKTRİN DAYANAĞI: JP 1-02 yalnızca SALUTE'un açılımını verir (size, activity, location, unit, time, equipment) ve SITREP'i
    "bir raporlayan birliğin bölgesindeki durumu veren rapor" diye tanımlar. LACE JP 1-02'de YOKTUR (liquids, ammunition, casualties,
    equipment: standart küçük birlik durum raporudur, alanlar genel bilgidir; bkz. docs/DOKTRIN_NOTLARI_RAPORLAR.md).

    Parametreler:
        0: tür <STRING>  "SALUTE" | "SITREP" | "LACE"
        1: veri <ARRAY of STRING>

    Dönüş: [geçerli mi <BOOL>, hatalar <ARRAY of STRING>]
*/

params [["_type", "", [""]], ["_data", [], [[]]]];

private _errors = [];
private _allStrings = {count (_this select {!(_x isEqualType "")}) == 0};

private _length = switch (_type) do {
    case "SALUTE": {6};
    case "SITREP": {6};
    case "LACE":   {8};
    default {-1};
};

if (_length < 0) exitWith {[false, ["Rapor türü geçersiz."]]};
if (count _data != _length || {!(_data call _allStrings)}) exitWith {[false, ["Geçersiz rapor verisi."]]};

switch (_type) do {
    case "SALUTE": {
        _data params ["_size", "_activity", "_location", "_unit", "_time", "_equipment"];
        if (_size isEqualTo "" || {count _size > 60}) then {_errors pushBack "S (Size): büyüklük gerekli (örn. 12 kişi)."};
        if (_activity isEqualTo "" || {count _activity > 60}) then {_errors pushBack "A (Activity): faaliyet gerekli."};
        if !(_location isEqualTo "OWN" || {(_location select [0, 1]) isEqualTo "M"}) then {_errors pushBack "L (Location): konum seçin."};
        if (_unit isEqualTo "" || {count _unit > 60}) then {_errors pushBack "U (Unit): birlik/kimlik gerekli (bilinmiyorsa 'BİLİNMİYOR')."};
        if (count _time > 20) then {_errors pushBack "T (Time): en çok 20 karakter."};
        if (_equipment isEqualTo "" || {count _equipment > 60}) then {_errors pushBack "E (Equipment): teçhizat gerekli."};
    };
    case "SITREP": {
        if ((_data select 0) isEqualTo "") then {_errors pushBack "SITREP: faaliyet gerekli."};
        if (count (_data select {count _x > 120}) > 0) then {_errors pushBack "SITREP: her alan en çok 120 karakter."};
    };
    case "LACE": {
        {
            private _status = _data select (_x * 2);
            private _note = _data select (_x * 2 + 1);
            if !(_status in ["GREEN", "AMBER", "RED", "BLACK"]) then {_errors pushBack format ["LACE: %1 durumu seçilmedi.", ["Liquids", "Ammunition", "Casualties", "Equipment"] select _x]};
            if (count _note > 80) then {_errors pushBack "LACE: not en çok 80 karakter."};
        } forEach [0, 1, 2, 3];
    };
};

[_errors isEqualTo [], _errors]
