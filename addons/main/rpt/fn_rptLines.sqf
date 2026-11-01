/*
    Fonksiyon: TC2_fnc_rptLines
    Çalışma yeri: Her makine (saf fonksiyon)

    Raporu okunur satırlara çevirir. LACE durum renkleri (GREEN / AMBER / RED / BLACK) birliğin SOP'una göre yüzde eşiği taşır;
    tipik kullanım: yeşil %80-100, amber %60-79, kırmızı %40-59, siyah %40 altı (doğrulanmamış genel bilgi).

    Parametreler:
        0: tür <STRING>
        1: veri <ARRAY of STRING>
        2: ek bilgi <ARRAY>  [konum grid metni <STRING>, otomatik doğrulanan LACE verisi <ARRAY>]  (isteğe bağlı)

    Dönüş: [[etiket, değer]] <ARRAY>
*/

params [["_type", "", [""]], ["_data", [], [[]]], ["_extra", [], [[]]]];

private _grid = _extra param [0, ""];
private _auto = _extra param [1, []];

private _statusName = {
    switch (_this) do {
        case "GREEN": {"YEŞİL"};
        case "AMBER": {"AMBER"};
        case "RED":   {"KIRMIZI"};
        case "BLACK": {"SİYAH"};
        default {_this};
    }
};

private _lines = [];

switch (_type) do {
    case "SALUTE": {
        _data params ["_size", "_activity", "", "_unit", "_time", "_equipment"];
        _lines = [
            ["S  SIZE (büyüklük)", _size],
            ["A  ACTIVITY (faaliyet)", _activity],
            ["L  LOCATION (konum)", _grid],
            ["U  UNIT (birlik)", _unit],
            ["T  TIME (zaman)", ["şimdi", _time] select !(_time isEqualTo "")],
            ["E  EQUIPMENT (teçhizat)", _equipment]
        ];
    };
    case "SITREP": {
        _lines = [
            ["KONUM", _grid],
            ["FAALİYET", _data select 0],
            ["DÜŞMAN", _data select 1],
            ["PERSONEL", _data select 2],
            ["LOJİSTİK", _data select 3],
            ["NİYET", _data select 4],
            ["NOTLAR", _data select 5]
        ] select {!((_x select 1) isEqualTo "")};
    };
    case "LACE": {
        {
            _lines pushBack [
                ["L  LIQUIDS (su)", "A  AMMUNITION (mühimmat)", "C  CASUALTIES (kayıp)", "E  EQUIPMENT (teçhizat)"] select _x,
                format ["%1%2", (_data select (_x * 2)) call _statusName, ["", "  -  " + (_data select (_x * 2 + 1))] select !((_data select (_x * 2 + 1)) isEqualTo "")]
            ];
        } forEach [0, 1, 2, 3];

        if !(_auto isEqualTo []) then {
            _auto params ["_alive", "_initial", "_wounded", "_vehicle"];
            _lines pushBack ["DOĞRULANAN (sistem)", format ["mevcut %1/%2   yaralı/etkisiz %3   araç hasarı %4 yüzde", _alive, _initial, _wounded, _vehicle]];
        };
    };
};

_lines
