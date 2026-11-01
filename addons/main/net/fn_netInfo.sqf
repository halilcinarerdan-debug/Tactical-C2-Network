/*
    Fonksiyon: TC2_fnc_netInfo
    Çalışma yeri: SADECE SUNUCU

    "Üs bilgisi": bir birimin ağındaki (aynı telsiz tipi + kanal + menzil) AÇIK oturumlara (üs terminalleri ve saha cihazları)
    bilgi satırı gönderir. Böylece sahadan gönderilen formlar (9-Line, topçu CFF) üstekilerin günlüğünde görünür;
    laptop başında olmayan JTAC'ın bile yaptığı üs tarafından izlenir. Satır yalnızca günlüğe düşer (bildirim/bip yok).

    Parametreler:
        0: kaynak birimin netId'si <STRING>  (oturumu açık olmalı; değilse hiçbir şey gönderilmez)
        1: bilgi metni <STRING>              (temizlenmiş olmalı: '<', '>', '&' içermez)

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_netId", "", [""]], ["_text", "", [""]]];

private _entry = [];
{
    if ((_x select 0) isEqualTo _netId) exitWith {_entry = _x};
} forEach (missionNamespace getVariable ["TC2_net_sessions", []]);

if (_entry isEqualTo []) exitWith {};

{
    if !(_x select 7) then {
        [_x select 1, "TC2_fnc_netReceive", ["INFO", "", _text, 0, ""]] call TC2_fnc_netToUnit;
    };
} forEach ([_entry] call TC2_fnc_netServerPeers);
