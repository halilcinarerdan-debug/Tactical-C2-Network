/*
    Fonksiyon: TC2_fnc_casOnAck
    Çalışma yeri: İSTEMCİ (sunucu casSend / casAbort / casReadback'e yanıt olarak gönderir)

    İşlem sonucunu durum satırına yazar ve kısa bildirim gösterir.

    Parametreler:
        0: kod <STRING>   "SENT" | "ABORTED" | "INVALID" | "NOT_JTAC" | "NO_TARGET" | "NO_LINK" | "COOLDOWN" | "NO_RADIO" | "NO_ACRE" | "NOT_FOUND" | erişim ret nedeni
        1: ek bilgi <ARRAY>  (SENT: [id, alıcı etiketi]; INVALID: hata listesi)

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_extra", [], [[]]]];

private _text = switch (_code) do {
    case "SENT":      {format ["İLETİLDİ | %1 | geri okuma bekleniyor", if (count _extra > 1) then {(_extra select 1) select [0, 22 min count (_extra select 1)]} else {"?"}]};
    case "ABORTED":   {"TALEP İPTAL EDİLDİ."};
    case "INVALID":   {format ["FORM GEÇERSİZ (%1 hata): %2", count _extra, if (_extra isEqualTo []) then {""} else {_extra select 0}]};
    case "NOT_JTAC":  {"JTAC yetkiniz yok."};
    case "NFA":       {"Hedef ATEŞ YASAK ALANI (NFA) içinde: talep reddedildi."};
    case "DANGER_CLOSE": {format ["DANGER CLOSE: hedefe dost %1 m (%2). Satır 17'ye komutan baş harflerini yazın.", _extra param [0, "?"], _extra param [1, ""]]};
    case "NO_TARGET": {"Alıcı ağda/menzilde değil."};
    case "NO_LINK":   {"BAĞLANTI YOK: JTAC ile aynı ağda değilsiniz."};
    case "COOLDOWN":  {"Bekleyin (3 sn aralık)."};
    case "NO_RADIO":  {"BAĞLANTI YOK: aktif telsiz yok."};
    case "NO_ACRE":   {"BAĞLANTI YOK: ACRE2 yüklü değil."};
    case "NOT_FOUND": {"Talep bulunamadı (süresi dolmuş)."};
    default {[_code] call TC2_fnc_accessReasonText};
};

missionNamespace setVariable ["TC2_cas_statusText", _text];

[_text, ["error", "success"] select (_code isEqualTo "SENT" || {_code isEqualTo "ABORTED"})] call TC2_fnc_notify;

call TC2_fnc_casUiUpdate;
call TC2_fnc_casPilotUpdate;
