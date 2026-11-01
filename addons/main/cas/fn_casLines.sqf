/*
    Fonksiyon: TC2_fnc_casLines
    Çalışma yeri: Her makine (saf fonksiyon)

    Form verisini doktrindeki 9 satır + remarks/restrictions biçiminde, okunur çiftler olarak verir.
    JTAC önizlemesi ve pilot penceresi aynı fonksiyonu kullanır; böylece ikisi aynı şeyi gösterir.

    Parametreler:
        0: form verisi <ARRAY>  (bkz. casValidate)
        1: platform <STRING>    "FW" | "RW"

    Dönüş: [[etiket, değer]] <ARRAY>
*/

params [["_data", [], [[]]], ["_platform", "FW", [""]]];

if (count _data != 19) exitWith {[]};

_data params [
    "", "", "_ip", "_heading", "_offset", "_distance", "_elevation", "_description", "_pos",
    "_markType", "_markCode", "_friendlyDist", "_friendlyDir", "_egress", "_remarks", "_fah", "_aca", "_dc", "_tot"
];

private _offsetText = switch (_offset) do {
    case "L": {"   OFFSET SOL"};
    case "R": {"   OFFSET SAĞ"};
    default {""};
};

private _markText = switch (_markType) do {
    case "SMOKE": {"DUMAN"};
    case "LASER": {format ["LAZER   KOD %1", _markCode]};
    case "IR":    {"IR"};
    default {"YOK"};
};

private _lines = [
    ["1  IP/BP", _ip],
    ["2  HEADING", format ["%1 derece (manyetik)%2", _heading, _offsetText]],
    ["3  DISTANCE", format ["%1 %2", _distance, ["m (BP merkezinden)", "nm (IP'den)"] select (_platform isEqualTo "FW")]],
    ["4  ELEVATION", format ["%1 ft MSL", _elevation]],
    ["5  TARGET", _description],
    ["6  LOCATION", format ["%1   (datum: ARMA grid)", [_pos] call TC2_fnc_casGrid]],
    ["7  MARK", _markText],
    ["8  FRIENDLIES", if (_friendlyDist < 0) then {"YOK"} else {format ["%1 m, hedefin %2 yönünde", _friendlyDist, _friendlyDir]}],
    ["9  EGRESS", _egress]
];

if !(_remarks isEqualTo "") then {_lines pushBack ["REMARKS", _remarks]};
if (_fah >= 0) then {_lines pushBack ["KISIT: SON SALDIRI YÖNÜ", format ["%1 derece", _fah]]};
if !(_aca isEqualTo "") then {_lines pushBack ["KISIT: ACA", _aca]};
if !(_dc isEqualTo "") then {_lines pushBack ["KISIT: DANGER CLOSE", format ["komutan: %1", toUpper _dc]]};
if !(_tot isEqualTo "") then {_lines pushBack ["KISIT: TOT/TTT", _tot]};

_lines
