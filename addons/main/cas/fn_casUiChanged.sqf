/*
    Fonksiyon: TC2_fnc_casUiChanged
    Çalışma yeri: İstemci (form kutularının seçim değişimi)

    Doktrin kurallarını forma yansıtır:
      - Type 1 seçilirse BOT'a kilitlenir (BOC kapalı): Type 1 her zaman BOT.
      - Lazer işaretinde kod alanı açılır, aksi halde boşaltılıp kapatılır.
      - Hedef konumu (işaret) seçilince yükseklik (ft MSL) otomatik dolar; tanım boşsa "DÜŞMAN PİYADE" yazılır.
      - Alıcı seçilince mesafe satırının birimi (sabit kanat nm / döner kanat m) güncellenir.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

private _type = _display displayCtrl 92201;
private _bot = _display displayCtrl 92202;
private _mark = _display displayCtrl 92210;
private _code = _display displayCtrl 92211;
private _target = _display displayCtrl 92209;
private _recipient = _display displayCtrl 92200;

if (isNull _type || {isNull _bot} || {isNull _mark} || {isNull _code} || {isNull _target} || {isNull _recipient}) exitWith {};

if ((_type lbData (lbCurSel _type)) isEqualTo "1") then {
    _bot lbSetCurSel 0;
    _bot ctrlEnable false;
} else {
    _bot ctrlEnable true;
};

if ((_mark lbData (lbCurSel _mark)) isEqualTo "LASER") then {
    _code ctrlEnable true;
} else {
    _code ctrlSetText "";
    _code ctrlEnable false;
};

private _markerId = parseNumber (_target lbData (lbCurSel _target));
if (_markerId > 0) then {
    private _marker = [];
    {
        if ((_x select 0) == _markerId) exitWith {_marker = _x};
    } forEach ((missionNamespace getVariable ["TC2_cop_data", [[], []]]) select 1);

    if !(_marker isEqualTo []) then {
        (_display displayCtrl 92207) ctrlSetText str (round (((_marker select 2) select 2) * 3.28084));
        if ((ctrlText (_display displayCtrl 92208)) isEqualTo "") then {
            (_display displayCtrl 92208) ctrlSetText ([_marker select 1] call TC2_fnc_copTypeName);
        };
    };
};

private _platform = "FW";
private _recipientNet = _recipient lbData (lbCurSel _recipient);
{
    if ((_x select 0) isEqualTo _recipientNet) exitWith {_platform = _x select 2};
} forEach ((missionNamespace getVariable ["TC2_cas_data", [false, [], []]]) select 1);

(_display displayCtrl 92304) ctrlSetText (["  3  DISTANCE (m, BP'den)", "  3  DISTANCE (nm, IP'den)"] select (_platform isEqualTo "FW"));
