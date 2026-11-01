/*
    Fonksiyon: TC2_fnc_casUiGather
    Çalışma yeri: İstemci

    Form alanlarını 19 elemanlı form verisine (bkz. casValidate) çevirir. Boş sayı alanları geçersiz değer olarak
    gönderilir ki doğrulama açıkça hata versin (ör. boş heading = -1). Boş "son saldırı yönü" ve "dost mesafesi" = -1 (yok).

    Parametreler: yok
    Dönüş: [form verisi <ARRAY>, alıcı netId <STRING>, platform <STRING>]  (pencere yoksa [[], "", "FW"])
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {[[], "", "FW"]};

private _selected = {private _control = _display displayCtrl _this; _control lbData (lbCurSel _control)};
private _text = {ctrlText (_display displayCtrl _this)};
private _number = {private _value = ctrlText (_display displayCtrl _this); if (_value isEqualTo "") then {-1} else {parseNumber _value}};

private _markerId = parseNumber (92209 call _selected);
private _pos = [];
{
    if ((_x select 0) == _markerId) exitWith {_pos = _x select 2};
} forEach ((missionNamespace getVariable ["TC2_cop_data", [[], []]]) select 1);

private _elevationText = 92207 call _text;

private _data = [
    parseNumber (92201 call _selected),
    92202 call _selected,
    92203 call _text,
    92204 call _number,
    92205 call _selected,
    92206 call _number,
    if (_elevationText isEqualTo "") then {-99999} else {parseNumber _elevationText},
    92208 call _text,
    _pos,
    92210 call _selected,
    92211 call _text,
    92212 call _number,
    92213 call _selected,
    92214 call _text,
    92215 call _text,
    92216 call _number,
    92217 call _text,
    92218 call _text,
    92219 call _text
];

private _recipientNet = 92200 call _selected;
private _platform = "FW";
{
    if ((_x select 0) isEqualTo _recipientNet) exitWith {_platform = _x select 2};
} forEach ((missionNamespace getVariable ["TC2_cas_data", [false, [], []]]) select 1);

[_data, _recipientNet, _platform]
