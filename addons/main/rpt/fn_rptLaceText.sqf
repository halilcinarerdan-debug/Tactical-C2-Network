/*
    Fonksiyon: TC2_fnc_rptLaceText
    Çalışma yeri: İstemci (saf fonksiyon)

    Bir birliğin LACE bilgisini structured text olarak üretir (harita BİRİM / LACE paneli).

    Parametreler:
        0: etiket <STRING>   1: lace <ARRAY>  (rptLaceInfo çıktısı; boş = yetki yok)

    Dönüş: <STRING> structured text gövdesi (parseText'e verilir)
*/

params [["_label", "", [""]], ["_lace", [], [[]]]];

if (_lace isEqualTo []) exitWith {
    format ["<t color='#40ff59'>%1</t><br/><t color='#aaaaaa'>LACE bilgisi yalnızca Level 2 ve üstü, izleme modunda olmayan oturumlarda görünür.</t>", _label]
};

_lace params ["_auto", "_report"];
_auto params ["_alive", "_initial", "_wounded", "_vehicle"];

private _status = [_lace] call TC2_fnc_rptLaceStatus;
private _color = switch (_status) do {
    case "GREEN": {"#40ff59"};
    case "AMBER": {"#ffcc33"};
    case "RED":   {"#ff6a33"};
    case "":      {"#bbbbbb"};
    default {"#bbbbbb"};
};

private _text = format [
    "<t color='#40ff59'>%1</t>   <t color='%2'>GENEL: %3</t><br/><t color='#1f9930'>DOĞRULANAN (sistem)</t>  mevcut %4/%5   yaralı/etkisiz %6   araç hasarı %7 yüzde",
    _label, _color, _status, _alive, _initial, _wounded, _vehicle
];

if (_report isEqualTo []) then {
    _text = _text + "<br/><t color='#aaaaaa'>Lider LACE raporu yok (son 45 dk). Sayılar sistemden okunur.</t>";
} else {
    _text = _text + format ["<br/><t color='#1f9930'>LİDER RAPORU</t>  %1 dk önce", floor ((_report select 0) / 60)];
    {
        _text = _text + format ["<br/>%1: %2", _x select 0, _x select 1];
    } forEach ([ "LACE", _report select 1, [] ] call TC2_fnc_rptLines);
};

_text
