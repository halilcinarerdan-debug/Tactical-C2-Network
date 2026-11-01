/*
    Fonksiyon: TC2_fnc_rptOnAck
    Çalışma yeri: İSTEMCİ (sunucu rptSend / rptVerify'a yanıt olarak gönderir)

    Parametreler:
        0: kod <STRING>  "SENT" | "VERIFIED" | "INVALID" | "COOLDOWN" | "NOT_S2" | "NOT_FOUND" | "ALREADY" | "NO_POS" | "VIEW_ONLY" | "NO_LEVEL" | erişim ret nedeni
        1: ek bilgi <ARRAY>  (SENT: [id, tür], VERIFIED: [id], INVALID: [hatalar])

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_extra", [], [[]]]];

private _text = switch (_code) do {
    case "SENT":       {format ["Rapor gönderildi (#%1 %2).", _extra param [0, "?"], _extra param [1, ""]]};
    case "VERIFIED":   {format ["SALUTE #%1 doğrulandı; düşman işareti haritada.", _extra param [0, "?"]]};
    case "INVALID":    {_extra param [0, ["Form geçersiz."]] joinString " "};
    case "COOLDOWN":   {"Çok sık gönderim; birkaç saniye bekleyin."};
    case "NOT_S2":     {"Doğrulama yalnızca S2 (İstihbarat) ya da CO içindir."};
    case "NOT_FOUND":  {"Rapor bulunamadı."};
    case "ALREADY":    {"Bu rapor zaten doğrulandı."};
    case "NO_POS":     {"Seçilen konum artık geçerli değil."};
    case "VIEW_ONLY":  {"Bu cihaz izleme modunda: rapor gönderemez."};
    case "NO_LEVEL":   {"Rapor yazmak için en az Level 2 (Mavi kart) gerekir."};
    default {[_code] call TC2_fnc_accessReasonText};
};

missionNamespace setVariable ["TC2_rpt_statusText", _text];
[_text, ["error", "success"] select (_code in ["SENT", "VERIFIED"])] call TC2_fnc_notify;

if (_code isEqualTo "SENT") then {
    // Formu temizle (durum seçimleri ve metinler).
    private _display = findDisplay 92000;
    if (!isNull _display) then {
        {(_display displayCtrl _x) ctrlSetText ""} forEach [92720, 92721, 92722, 92723, 92724, 92725];
        {(_display displayCtrl _x) lbSetCurSel 0} forEach [92710, 92711, 92712, 92713, 92716];
    };
};

call TC2_fnc_rptUiRequest;
call TC2_fnc_rptUiUpdate;
