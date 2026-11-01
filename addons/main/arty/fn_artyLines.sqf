/*
    Fonksiyon: TC2_fnc_artyLines
    Çalışma yeri: Her makine (saf fonksiyon)

    CFF'i doktrindeki üç aktarım biçiminde okunur satırlar olarak verir (ATP 3-09.30, 4-8):
      AKTARIM 1  gözlemci kimliği + uyarı emri (görev türü, konum yöntemi)
      AKTARIM 2  hedef konumu
      AKTARIM 3  hedef tanımı + angajman yöntemi + ateş ve kontrol yöntemi
    Gözlemci önizlemesi ve FDC ekranı aynı fonksiyonu kullanır.

    Parametreler:
        0: form verisi <ARRAY>  (bkz. artyValidate)
        1: gözlemci çağrı adı <STRING>
        2: çözülmüş hedef konumu <ARRAY>  (isteğe bağlı; verilirse GRID olarak da yazılır)

    Dönüş: [[etiket, değer]] <ARRAY>
*/

params [["_data", [], [[]]], ["_observer", "", [""]], ["_resolved", [], [[]]]];

if (count _data != 15) exitWith {[]};

_data params [
    "_type", "_method", "_grid", "_polar", "_shift", "_description", "_protection", "_adjustType",
    "_dangerClose", "_mark", "_trajectory", "_projectile", "_volume", "_control", "_duration"
];

private _typeText = switch (_type) do {
    case "ADJUST":    {"ADJUST FIRE"};
    case "FFE":       {"FIRE FOR EFFECT"};
    case "SUPPRESS":  {"SUPPRESS"};
    case "IMM_SUPP":  {"IMMEDIATE SUPPRESSION"};
    case "IMM_SMOKE": {"IMMEDIATE SMOKE"};
    default {_type};
};

private _locationText = switch (_method) do {
    case "GRID":  {
        if (count _grid == 3) then {format ["GRID %1   ALTITUDE %2 m", [_grid] call TC2_fnc_casGrid, round (_grid select 2)]} else {"GRID"}
    };
    case "POLAR": {format ["POLAR   YÖN %1   MESAFE %2 m   DİKEY %3 m", _polar param [0, 0], _polar param [1, 0], _polar param [2, 0]]};
    case "SHIFT": {format ["SHIFT %1   YÖN %2   %3 %4   %5 %6   %7 %8", _shift param [0, "?"], _shift param [1, 0],
        ["SAĞ", "SOL"] select ((_shift param [2, 0]) < 0), abs (_shift param [2, 0]),
        ["ADD", "DROP"] select ((_shift param [3, 0]) < 0), abs (_shift param [3, 0]),
        ["UP", "DOWN"] select ((_shift param [4, 0]) < 0), abs (_shift param [4, 0])]};
    default {""};
};

private _protectionText = switch (_protection) do {
    case "OPEN":   {"AÇIKTA"};
    case "DUGIN":  {"SİPERDE"};
    case "BUNKER": {"ÜSTÜ KAPALI SIĞINAKTA"};
    default {_protection};
};

private _engagement = [
    ["ALAN", "HASSAS (DESTRUCTION)"] select (_adjustType isEqualTo "PRECISION"),
    ["", "DANGER CLOSE"] select _dangerClose,
    ["", "MARK"] select _mark,
    ["ALÇAK AÇI", "YÜKSEK AÇI"] select (_trajectory isEqualTo "HIGH"),
    _projectile,
    format ["%1 mermi/top", _volume]
];

private _controlText = switch (_control) do {
    case "AMC":            {"AT MY COMMAND"};
    case "CANNOT_OBSERVE": {"CANNOT OBSERVE"};
    default {"FIRE WHEN READY"};
};
if (_duration > 0) then {_controlText = _controlText + format ["   DURATION %1 sn", _duration]};

private _lines = [
    ["AKTARIM 1", format ["%1,  %2,  %3", _observer, _typeText, _method]],
    ["AKTARIM 2", _locationText],
    ["AKTARIM 3", format ["%1  (%2)", _description, _protectionText]],
    ["ANGAJMAN", (_engagement select {!(_x isEqualTo "")}) joinString ",  "],
    ["KONTROL", _controlText]
];

if (!(_resolved isEqualTo []) && {!(_method isEqualTo "GRID")}) then {
    _lines pushBack ["HESAPLANAN KONUM", format ["GRID %1", [_resolved] call TC2_fnc_casGrid]];
};

_lines
