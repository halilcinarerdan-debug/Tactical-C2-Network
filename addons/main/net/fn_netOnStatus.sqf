/*
    Fonksiyon: TC2_fnc_netOnStatus
    Çalışma yeri: İSTEMCİ (sunucu netServerReport'a yanıt olarak gönderir)

    Sunucunun BAĞLANTI kararını saklar ve ekrandaki durum satırını günceller.

    Parametreler:
        0: kod <STRING>   "LINK" | "NO_PEERS" | "NO_RADIO" | "NO_ACRE" | erişim ret nedeni
        1: menzildeki eş sayısı <NUMBER>
        2: telsiz taban sınıfı <STRING>
        3: kanal <NUMBER>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_count", 0, [0]], ["_base", "", [""]], ["_channel", -1, [0]]];

missionNamespace setVariable ["TC2_net_status", [_code, _count, _base, _channel]];
missionNamespace setVariable ["TC2_net_statusTime", diag_tickTime];

call TC2_fnc_netUiUpdate;
