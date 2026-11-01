/*
    Fonksiyon: TC2_fnc_artyOnEvent
    Çalışma yeri: İSTEMCİ (sunucu FDC komutlarını / MTO'yu / CFF bildirimini anında gönderir)

    Bildirim gösterir (BEEP: yeni CFF bipi) ve ekranı yeniler. Gözlemci cihaza bakmayabilir (gökyüzünü izler), bu yüzden
    SHOT / SPLASH / READY / ROUNDS COMPLETE gibi satırlar bildirim olarak da çıkar. Tam günlük sunucudan poll ile gelir.

    Parametreler:
        0: görev id <NUMBER>
        1: metin <STRING>
        2: ton <STRING>  "INFO" | "GOOD" | "BAD" | "BEEP"

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_id", -1, [0]], ["_text", "", [""]], ["_tone", "INFO", [""]]];

switch (_tone) do {
    case "BEEP": {
        if (isClass (configFile >> "CfgSounds" >> "FD_Timer_F")) then {playSound "FD_Timer_F"};
        [_text, "info"] call TC2_fnc_notify;
    };
    case "GOOD": {[_text, "success"] call TC2_fnc_notify};
    case "BAD":  {[_text, "error"] call TC2_fnc_notify};
    default {};
};

call TC2_fnc_artyUiRequest;
