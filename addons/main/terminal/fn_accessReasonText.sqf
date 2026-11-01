/*
    Fonksiyon: TC2_fnc_accessReasonText
    Çalışma yeri: Her makine (saf fonksiyon)

    accessCheck'in neden kodunu oyuncuya gösterilecek Türkçe mesaja çevirir.
    Metinler '<' ve '&' içermez (TC2_fnc_notify structured text kullanır).

    Parametreler:
        0: neden kodu <STRING>

    Dönüş: <STRING>
*/

params [["_reason", "", [""]]];

switch (_reason) do {
    case "OK":              {"ERİŞİM ONAYLANDI."};
    case "NO_CARD":         {"ERİŞİM REDDEDİLDİ: Kimlik kartı (CAC) bulunamadı."};
    case "TOO_FAR":         {"ERİŞİM REDDEDİLDİ: Terminale çok uzaksınız."};
    case "DEAD":            {"ERİŞİM REDDEDİLDİ: Birim etkisiz."};
    case "UNCONSCIOUS":     {"ERİŞİM REDDEDİLDİ: Bilinçsiz durumdasınız."};
    case "DISABLED":        {"Terminal sistemi devre dışı."};
    case "FIELD_DISABLED":  {"Saha cihazı devre dışı."};
    case "NO_DEVICE":       {"ERİŞİM REDDEDİLDİ: Saha cihazı eşyası (tablet) yok."};
    case "VIEW_ONLY":       {"SALT OKUNUR MOD: bu cihazla yalnızca harita ve işaretleri izleyebilirsiniz."};
    case "NO_LEVEL":        {"YETKİ YETERSİZ: bu işlem için seviye kartınız/yetkiniz yok."};
    case "NOT_TERMINAL":    {"Bu obje bir komuta terminali değil."};
    case "BAD_PARAMS":      {"Geçersiz erişim talebi."};
    case "TIMEOUT":         {"SUNUCU YANIT VERMEDİ: Erişim talebi zaman aşımına uğradı. (Sunucuda mod yüklü mü?)"};
    default                 {format ["ERİŞİM REDDEDİLDİ (%1).", _reason]};
};
