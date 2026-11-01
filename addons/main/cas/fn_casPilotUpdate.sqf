/*
    Fonksiyon: TC2_fnc_casPilotUpdate
    Çalışma yeri: İstemci

    Pilot penceresini günceller: başlık, 9 satır, hangi geri okuma kutularının görüneceği (yalnızca verilmiş kısıtlar),
    renkli sonuç. Pencere kapalıysa ya da gelen talep yoksa bir şey yapmaz.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92100;
if (isNull _display) exitWith {};

private _incoming = missionNamespace getVariable ["TC2_cas_incoming", []];
if (_incoming isEqualTo []) exitWith {};

_incoming params ["_id", "_jtac", "_pilot", "_data", "_platform", "_state", "_results"];

(_display displayCtrl 92102) ctrlSetText format ["  CAS 9-LINE  #%1  |  %2", _id, _jtac select [0, 26 min count _jtac]];

private _dim = "#1f9930";
private _text = format ["<t color='#ffffff'>%1, bu %2, TYPE %3 kontrol, %4.</t><br/><br/>", _pilot, _jtac, _data select 0, _data select 1];

{
    _x params ["_label", "_value"];
    _text = _text + format ["<t color='%1'>%2</t>   %3<br/>", _dim, _label, _value];
} forEach ([_data, _platform] call TC2_fnc_casLines);

private _stateText = switch (_state) do {
    case "SENT":          {"<t color='#ffcc33'>GERİ OKUMA BEKLENİYOR</t>"};
    case "READBACK_OK":   {"<t color='#40ff59'>GERİ OKUMA DOĞRU</t>"};
    case "READBACK_FAIL": {"<t color='#ff5555'>GERİ OKUMA YANLIŞ</t>"};
    case "ABORTED":       {"<t color='#ff5555'>JTAC TALEBİ İPTAL ETTİ</t>"};
    default {""};
};
_text = _text + "<br/>" + _stateText;

(_display displayCtrl 92104) ctrlSetStructuredText parseText format ["<t size='0.8'>%1</t>", _text];

// Hangi kutular gerekli? Yükseklik ve konum her zaman; kısıtlar yalnızca verilmişse.
private _required = [true, true, (_data select 15) >= 0, !((_data select 17) isEqualTo ""), !((_data select 16) isEqualTo ""), !((_data select 18) isEqualTo "")];
{
    (_display displayCtrl (92110 + _forEachIndex)) ctrlShow _x;
    (_display displayCtrl (92120 + _forEachIndex)) ctrlShow _x;
} forEach _required;

(_display displayCtrl 92116) ctrlEnable !(_state isEqualTo "ABORTED");

(_display displayCtrl 92117) ctrlSetStructuredText parseText format ["<t size='0.7'>%1</t>", [_results] call TC2_fnc_casResultText];
