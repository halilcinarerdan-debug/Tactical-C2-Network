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

private _pending = missionNamespace getVariable ["TC2_net_pendingText", ""];

// Başarısız MSG: mesajın iletilmediğini açıkça söyle.
if (_type isEqualTo "MSG" && {!(_code isEqualTo "SENT")} && {!(_code isEqualTo "COOLDOWN")}) then {
    [format ["İLETİLMEDİ: %1", _pending], _red] call TC2_fnc_netLog;
};

switch (_code) do {
    case "SENT": {
        if (_type isEqualTo "PING") then {
            [format ["PING iletildi: %1 terminal", _count], "#1f9930"] call TC2_fnc_netLog;
        } else {
            [format ["SEN: %1   (iletildi: %2 terminal)", _pending, _count], "#40ff59"] call TC2_fnc_netLog;
        };
    };
    case "NO_PEERS": {["BAĞLANTI YOK: menzilde (aynı telsiz tipi ve kanalda) terminal yok.", _red] call TC2_fnc_netLog};
    case "NO_RADIO": {["BAĞLANTI YOK: aktif telsiz yok.", _red] call TC2_fnc_netLog};
    case "NO_ACRE":  {["BAĞLANTI YOK: ACRE2 yüklü değil.", _red] call TC2_fnc_netLog};
    case "COOLDOWN": {["Bekleyin (2 sn aralık).", "#ffcc33"] call TC2_fnc_netLog};
    default {[[_code] call TC2_fnc_accessReasonText, _red] call TC2_fnc_netLog};
};
