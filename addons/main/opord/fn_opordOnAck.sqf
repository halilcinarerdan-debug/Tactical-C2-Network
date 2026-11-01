/*
    Fonksiyon: TC2_fnc_opordOnAck
    Çalışma yeri: İSTEMCİ (sunucu opordEdit'e yanıt olarak gönderir)

    Parametreler:
        0: kod <STRING>  "ACKED" | "SAVED" | "TEMPLATE_OK" | "NOT_EDITOR" | "EMPTY" | "EXISTS" | "NO_SECTION" | erişim ret nedeni
        1: ek bilgi <ARRAY>  (ACKED / SAVED: [sürüm])

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_extra", [], [[]]]];

private _text = switch (_code) do {
    case "ACKED":       {format ["OPORD onayınız kaydedildi (sürüm %1).", _extra param [0, "?"]]};
    case "SAVED":       {format ["Bölüm kaydedildi (sürüm %1).", _extra param [0, "?"]]};
    case "TEMPLATE_OK": {"Boş OPORD şablonu oluşturuldu."};
    case "NOT_EDITOR":  {"OPORD'u yalnızca Level 3 düzenleyebilir."};
    case "EMPTY":       {"Henüz yayımlanmış OPORD yok."};
    case "EXISTS":      {"Zaten bir OPORD var; şablon yalnızca belge yokken oluşturulur."};
    case "NO_SECTION":  {"Bölüm bulunamadı."};
    default {[_code] call TC2_fnc_accessReasonText};
};

missionNamespace setVariable ["TC2_opord_statusText", _text];
[_text, ["error", "success"] select (_code in ["ACKED", "SAVED", "TEMPLATE_OK"])] call TC2_fnc_notify;

call TC2_fnc_opordUiRequest;
