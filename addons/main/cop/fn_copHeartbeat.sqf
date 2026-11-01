/*
    Fonksiyon: TC2_fnc_copHeartbeat
    Çalışma yeri: İSTEMCİ (10 sn'de bir)

    Aktif ACRE telsizini okuyup sunucuya bildirir (copFieldReport). Telsiz yoksa gönderilmez.

    Parametreler: yok
    Dönüş: yok
*/

if (!(missionNamespace getVariable ["TC2_terminal_enabled", true])) exitWith {};
if (isNull ACE_player) exitWith {};

// Tablet kuralı: hava aracı mürettebatı dışında, tablet yoksa terminale konum/durum bildirilmez (ve dolayısıyla ağdan bilgi alınmaz).
if !([ACE_player] call TC2_fnc_hasTablet) exitWith {};

private _state = call TC2_fnc_netGetRadioState;
if !(_state select 0) exitWith {};

private _args = [ACE_player, _state];

if (isServer) then {
    _args call TC2_fnc_copFieldReport;
} else {
    _args remoteExecCall ["TC2_fnc_copFieldReport", 2];
};
