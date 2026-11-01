/*
    Fonksiyon: TC2_fnc_artyUiGather
    Çalışma yeri: İstemci

    TOPÇU sekmesi panel A alanlarını 15 elemanlı CFF verisine çevirir (bkz. artyValidate). Boş sayı alanları geçersiz değerle gönderilir
    ki doğrulama açıkça hata versin. GRID için konum, seçilen HARİTA işaretinden alınır.

    Parametreler: yok
    Dönüş: [CFF verisi <ARRAY>, alıcı FDC netId <STRING>]  (pencere yoksa [[], ""])
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {[[], ""]};

private _selected = {private _control = _display displayCtrl _this; _control lbData (lbCurSel _control)};
private _text = {ctrlText (_display displayCtrl _this)};
private _number = {private _value = ctrlText (_display displayCtrl _this); if (_value isEqualTo "") then {-99999} else {parseNumber _value}};

private _method = 92402 call _selected;
private _reference = 92408 call _selected;

private _grid = [];
if (_method isEqualTo "GRID" && {(_reference select [0, 1]) isEqualTo "M"}) then {
    private _id = parseNumber (_reference select [1, (count _reference) - 1]);
    {
        if ((_x select 0) == _id) exitWith {_grid = _x select 2};
    } forEach ((missionNamespace getVariable ["TC2_cop_data", [[], []]]) select 1);
};

private _polar = [];
if (_method isEqualTo "POLAR") then {_polar = [92403 call _number, 92404 call _number, 92405 call _number]};

private _shift = [];
if (_method isEqualTo "SHIFT") then {
    _shift = [_reference, 92403 call _number, 92404 call _number, 92405 call _number, 92406 call _number];
};

private _volumeText = 92416 call _text;
private _durationText = 92418 call _text;

private _data = [
    92401 call _selected,
    _method,
    _grid,
    _polar,
    _shift,
    92409 call _text,
    92410 call _selected,
    92411 call _selected,
    (92412 call _selected) isEqualTo "1",
    (92413 call _selected) isEqualTo "1",
    92414 call _selected,
    92415 call _selected,
    if (_volumeText isEqualTo "") then {0} else {parseNumber _volumeText},
    92417 call _selected,
    if (_durationText isEqualTo "") then {0} else {parseNumber _durationText}
];

[_data, 92400 call _selected]
