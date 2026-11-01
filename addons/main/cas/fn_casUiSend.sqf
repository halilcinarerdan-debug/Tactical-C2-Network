/*
    Fonksiyon: TC2_fnc_casUiSend
    Çalışma yeri: İSTEMCİ (GÖNDER düğmesi)

    Formu toplar, doktrine göre ÖN KONTROL eder (anında geri bildirim; sunucu yine kendi kararını verir) ve sunucuya gönderir.

    Parametreler: yok
    Dönüş: yok
*/

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _terminal) exitWith {};

([] call TC2_fnc_casUiGather) params ["_data", "_recipientNet", "_platform"];

if (_recipientNet isEqualTo "") exitWith {
    missionNamespace setVariable ["TC2_cas_statusText", "Alıcı seçin (ağdaki hava aracı mürettebatı)."];
    call TC2_fnc_casUiUpdate;
};

private _check = [_data, _platform] call TC2_fnc_casValidate;
if !(_check select 0) exitWith {
    missionNamespace setVariable ["TC2_cas_statusText", format ["FORM GEÇERSİZ (%1 hata): %2", count (_check select 1), (_check select 1) select 0]];
    call TC2_fnc_casUiUpdate;
};

missionNamespace setVariable ["TC2_cas_statusText", "Gönderiliyor..."];
call TC2_fnc_casUiUpdate;

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState, _data, _recipientNet];

if (isServer) then {
    _args call TC2_fnc_casSend;
} else {
    _args remoteExecCall ["TC2_fnc_casSend", 2];
};
