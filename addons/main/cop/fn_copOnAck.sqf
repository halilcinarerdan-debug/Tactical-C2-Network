/*
    Fonksiyon: TC2_fnc_copOnAck
    Çalışma yeri: İSTEMCİ (sunucu copPlace / copRemove'a yanıt olarak gönderir)

    İşlem sonucunu durum satırında gösterir ve haritayı hemen yeniler.

    Parametreler:
        0: kod <STRING>   "PLACED" | "REMOVED" | "COOLDOWN" | "LIMIT" | "NOT_FOUND" | "NO_RADIO" | "NO_ACRE" | erişim ret nedeni
        1: ek bilgi <STRING>  (PLACED için grid)

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_extra", "", [""]]];

private _red = [1, 0.35, 0.35, 1];

private _line = switch (_code) do {
    case "PLACED":    {["  İŞARET KONDU   |   DÜŞMAN PİYADE   |   grid " + _extra, [0.25, 1, 0.35, 1]]};
    case "REMOVED":   {["  İŞARET SİLİNDİ", [0.25, 1, 0.35, 1]]};
    case "COOLDOWN":  {["  Bekleyin (1.5 sn aralık).", [1, 0.8, 0.2, 1]]};
    case "LIMIT":     {["  Bu ağda en fazla 30 işaret olabilir; önce eskilerini silin.", _red]};
    case "NOT_FOUND": {["  İşaret bulunamadı (süresi dolmuş veya menzil dışı).", _red]};
    case "NO_RADIO":  {["  BAĞLANTI YOK   |   aktif telsiz yok", _red]};
    case "NO_ACRE":   {["  BAĞLANTI YOK   |   ACRE2 yüklü değil", _red]};
    default {["  " + ([_code] call TC2_fnc_accessReasonText), _red]};
};

missionNamespace setVariable ["TC2_cop_mode", ""];
[""] call TC2_fnc_copUiMode;
_line call TC2_fnc_copUiStatus;

call TC2_fnc_copUiRequest;
