/*
    Fonksiyon: TC2_fnc_artyOnAck
    Çalışma yeri: İSTEMCİ (sunucu artySendCff / artyObsAction / artyFdcAction'a yanıt olarak gönderir)

    İşlem sonucunu durum satırına yazar ve kısa bildirim gösterir.

    Parametreler:
        0: kod <STRING>
        1: ek bilgi <ARRAY>  (SENT: [id, FDC adı]; INVALID: hata listesi; DANGER_CLOSE: [mesafe, ad]; ACCEPTED: [hedef no]; NO_AMMO: [mühimmat])

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_extra", [], [[]]]];

private _first = _extra param [0, ""];
private _text = switch (_code) do {
    case "SENT":         {format ["CFF #%1 iletildi | FDC: %2", _first, (_extra param [1, "?"]) select [0, 22 min count (_extra param [1, "?"])]]};
    case "ACCEPTED":     {format ["MTO gönderildi | hedef %1", _first]};
    case "REJECTED":     {"CFF reddedildi."};
    case "EOM":          {"Görev sona erdi."};
    case "INVALID":      {format ["FORM GEÇERSİZ (%1 hata): %2", count _extra, _first]};
    case "NOT_OBSERVER": {"Gözlemci (FO/JFO) yetkiniz yok."};
    case "NOT_FDC":      {"FDC operatörü yetkiniz yok."};
    case "NO_FDC":       {"Alıcı FDC ağda/menzilde değil."};
    case "NO_POS":       {"Hedef konumu çözülemedi (bilinen nokta yok/görünmüyor)."};
    case "DANGER_CLOSE": {format ["DANGER CLOSE gerekli: dost %1 m (%2). Angajmanda DANGER CLOSE işaretleyin.", _first, _extra param [1, ""]]};
    case "CREEP":        {"DANGER CLOSE: menzil düzeltmesi en çok 100 m (creeping fire)."};
    case "BAD_STATE":    {"Bu işlem şu an uygun değil (görev durumu)."};
    case "NO_BATTERY":   {"Batarya seçilemedi/kullanılamaz."};
    case "NO_PLAYER_CREW": {"Bu bataryada oyuncu mürettebat yok (AI topçu desteklenmez)."};
    case "NO_AMMO":      {format ["Bataryada %1 mühimmatı yok.", _first]};
    case "OUT_OF_RANGE": {"Hedef bataryanın menzili dışında."};
    case "COOLDOWN":     {"Bekleyin (3 sn aralık)."};
    case "NOT_FOUND":    {"Görev bulunamadı (süresi dolmuş)."};
    case "NO_RADIO":     {"BAĞLANTI YOK: aktif telsiz yok."};
    case "NO_ACRE":      {"BAĞLANTI YOK: ACRE2 yüklü değil."};
    default {[_code] call TC2_fnc_accessReasonText};
};

missionNamespace setVariable ["TC2_arty_statusText", _text];

[_text, ["error", "success"] select (_code in ["SENT", "ACCEPTED", "REJECTED", "EOM"])] call TC2_fnc_notify;

call TC2_fnc_artyUiRequest;
