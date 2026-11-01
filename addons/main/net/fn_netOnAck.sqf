/*
    Fonksiyon: TC2_fnc_netOnAck
    Çalışma yeri: İSTEMCİ (sunucu netServerSend'e yanıt olarak gönderir)

    Gönderimin sonucunu günlüğe yazar. "BAĞLANTI YOK" uyarıları burada görünür.

    Parametreler:
        0: tür <STRING>
        1: kod <STRING>   "SENT" | "NO_PEERS" | "NO_RADIO" | "NO_ACRE" | "COOLDOWN" | erişim ret nedeni
        2: ulaşılan eş sayısı <NUMBER>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_type", "MSG", [""]], ["_code", "", [""]], ["_count", 0, [0]]];

private _red = "#ff5555";

switch (_code) do {
    case "SENT": {
        [format ["%1: %2 terminal", if (_type isEqualTo "PING") then {"PING iletildi"} else {"İLETİLDİ"}, _count], "#1f9930"] call TC2_fnc_netLog;
    };
    case "NO_PEERS": {["BAĞLANTI YOK: menzilde (aynı telsiz tipi ve kanalda) terminal yok.", _red] call TC2_fnc_netLog};
    case "NO_RADIO": {["BAĞLANTI YOK: aktif telsiz yok.", _red] call TC2_fnc_netLog};
    case "NO_ACRE":  {["BAĞLANTI YOK: ACRE2 yüklü değil.", _red] call TC2_fnc_netLog};
    case "COOLDOWN": {["Bekleyin (2 sn aralık).", "#ffcc33"] call TC2_fnc_netLog};
    default {[[_code] call TC2_fnc_accessReasonText, _red] call TC2_fnc_netLog};
};
