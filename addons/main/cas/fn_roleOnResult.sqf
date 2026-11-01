/*
    Fonksiyon: TC2_fnc_roleOnResult
    Çalışma yeri: İSTEMCİ (Zeus; sunucu roleSet sonucunu gönderir)

    Zeus'a rol atama/kaldırma sonucunu bildirir.

    Parametreler:
        0: birim adı <STRING>
        1: rol <STRING>  "JTAC" | "OBSERVER" | "FDC"
        2: verildi mi <BOOL>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_name", "", [""]], ["_role", "", [""]], ["_state", true, [true]]];

private _roleName = switch (_role) do {
    case "JTAC":     {"JTAC"};
    case "OBSERVER": {"GÖZLEMCİ (FO/JFO)"};
    case "FDC":      {"FDC OPERATÖRÜ"};
    case "CO":       {"BÖLÜK KOMUTANI (CO)"};
    case "S2":       {"İSTİHBARAT SUBAYI (S2)"};
    case "S4":       {"LOJİSTİK SUBAYI (S4)"};
    default {_role};
};

[format ["%1: %2 %3.", _name, _roleName, ["yetkisi KALDIRILDI", "olarak ATANDI"] select _state], ["info", "success"] select _state] call TC2_fnc_notify;
