/*
    Fonksiyon: TC2_fnc_medOnAck
    Çalışma yeri: İSTEMCİ (sunucu medSend / medCancel / medRespond'a yanıt olarak gönderir)

    Parametreler:
        0: kod <STRING>  "SENT" | "CANCELLED_OK" | "ACCEPTED_OK" | "INVALID" | "COOLDOWN" | "NO_CREW" | "NO_POS" | "NOT_ALLOWED" | "TAKEN" | "CANCELLED" | "VIEW_ONLY" | "NO_LEVEL" | erişim ret nedeni
        1: ek bilgi <ARRAY>  (SENT: [id, alıcı sayısı], ACCEPTED_OK: [id, ETA], INVALID: [hatalar])

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_extra", [], [[]]]];

private _text = switch (_code) do {
    case "SENT":          {format ["MEDEVAC talebi gönderildi (#%1, %2 mürettebat).", _extra param [0, "?"], _extra param [1, "?"]]};
    case "CANCELLED_OK":  {format ["MEDEVAC #%1 iptal edildi.", _extra param [0, "?"]]};
    case "ACCEPTED_OK":   {format ["MEDEVAC #%1 kabul edildi. Tahmini varış %2 dk.", _extra param [0, "?"], _extra param [1, "?"]]};
    case "INVALID":       {(_extra param [0, ["Form geçersiz."]]) joinString " "};
    case "COOLDOWN":      {"Çok sık gönderim; birkaç saniye bekleyin."};
    case "NO_CREW":       {"Ağınızda (aynı telsiz ve kanal, menzil içinde) helikopter mürettebatı yok."};
    case "NO_POS":        {"Seçilen alım yeri artık geçerli değil."};
    case "NOT_ALLOWED":   {"Bu talep için yetkiniz yok ya da talep geçersiz."};
    case "TAKEN":         {"Talep zaten başka mürettebat tarafından kabul edildi."};
    case "CANCELLED":     {"Talep iptal edilmiş."};
    case "VIEW_ONLY":     {"Bu cihaz izleme modunda: talep gönderemez."};
    case "NO_LEVEL":      {"MEDEVAC talebi için en az Level 2 (Mavi kart) gerekir."};
    default {[_code] call TC2_fnc_accessReasonText};
};

// Kabul eden mürettebatın kendi önbelleği: durum KABUL (KABUL düğmesi kaybolur)
if (_code isEqualTo "ACCEPTED_OK") then {
    {
        if ((_x select 0) == (_extra param [0, -1])) then {_x set [3, "ACCEPTED"]; _x set [4, "SEN"]};
    } forEach (missionNamespace getVariable ["TC2_med_incoming", []]);
};

missionNamespace setVariable ["TC2_med_statusText", _text];
[_text, ["error", "success"] select (_code in ["SENT", "CANCELLED_OK", "ACCEPTED_OK"])] call TC2_fnc_notify;

call TC2_fnc_medUiRequest;
call TC2_fnc_medUiUpdate;
