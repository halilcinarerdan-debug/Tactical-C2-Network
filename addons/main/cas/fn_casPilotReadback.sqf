/*
    Fonksiyon: TC2_fnc_casPilotReadback
    Çalışma yeri: İSTEMCİ PİLOT (GERİ OKU düğmesi)

    Pilotun yazdığı geri okumayı sunucuya gönderir. Karşılaştırma SUNUCUDADIR (casCompare); sonuç hem pilota
    hem JTAC'a renkli satırlar olarak döner. Yanlışsa pilot düzeltip tekrar okuyabilir.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92100;
if (isNull _display) exitWith {};

private _incoming = missionNamespace getVariable ["TC2_cas_incoming", []];
if (_incoming isEqualTo []) exitWith {};

private _text = {ctrlText (_display displayCtrl _this)};
private _number = {private _value = ctrlText (_display displayCtrl _this); if (_value isEqualTo "") then {-99999} else {parseNumber _value}};

private _answers = [
    92110 call _number,
    92111 call _text,
    92112 call _number,
    92113 call _text,
    92114 call _text,
    92115 call _text
];

private _args = [ACE_player, call TC2_fnc_netGetRadioState, _incoming select 0, _answers];

if (isServer) then {
    _args call TC2_fnc_casReadback;
} else {
    _args remoteExecCall ["TC2_fnc_casReadback", 2];
};
