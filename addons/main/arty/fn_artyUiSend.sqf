/*
    Fonksiyon: TC2_fnc_artyUiSend
    Çalışma yeri: İSTEMCİ (GÖNDER (CFF) düğmesi)

    Formu toplar, doktrine göre ÖN KONTROL eder (anında geri bildirim; sunucu yine kendi kararını verir) ve CFF'i sunucuya gönderir.

    Parametreler: yok
    Dönüş: yok
*/

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
if (isNull _terminal) exitWith {};

([] call TC2_fnc_artyUiGather) params ["_data", "_fdcNet"];

if (_fdcNet isEqualTo "") exitWith {
    missionNamespace setVariable ["TC2_arty_statusText", "Alıcı FDC seçin (ağdaki FDC operatörü)."];
    call TC2_fnc_artyUiUpdate;
};

private _check = [_data] call TC2_fnc_artyValidate;
if !(_check select 0) exitWith {
    missionNamespace setVariable ["TC2_arty_statusText", format ["FORM GEÇERSİZ (%1 hata): %2", count (_check select 1), (_check select 1) select 0]];
    call TC2_fnc_artyUiUpdate;
};

missionNamespace setVariable ["TC2_arty_forceNew", false];
missionNamespace setVariable ["TC2_arty_statusText", "Gönderiliyor..."];
call TC2_fnc_artyUiUpdate;

private _args = [ACE_player, _terminal, call TC2_fnc_netGetRadioState, _data, _fdcNet];

if (isServer) then {
    _args call TC2_fnc_artySendCff;
} else {
    _args remoteExecCall ["TC2_fnc_artySendCff", 2];
};
