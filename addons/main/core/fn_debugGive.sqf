/*
    Fonksiyon: TC2_fnc_debugGive
    Çalışma yeri: İstemci / birimin yerel olduğu makine (debug konsolu "Local Exec")

    TEST YARDIMCISI: kart ve tablet ver / al. Önceki kart/tablet eşyalarını temizleyip istenen seviyeyi verir, böylece
    Level 1 / 2 / 3 ve tablet kuralı tek komutla denenebilir.

    Parametreler:
        0: ne <STRING>  "RED" (Level 1) | "BLUE" (Level 2) | "GOLD" (Level 3) | "TABLET" | "CAC" (eski kart) | "NONE" (tüm kart ve tabletleri al)
        1: birim <OBJECT>  (varsayılan: player)

    Dönüş: yok

    Örnekler:
        ["BLUE"] call TC2_fnc_debugGive;      // Mavi kart (Level 2), Kırmızı/Altın/CAC kartı alınır
        ["TABLET"] call TC2_fnc_debugGive;    // saha tableti ekle
        ["NONE"] call TC2_fnc_debugGive;      // hepsini al
*/

params [["_what", "RED", [""]], ["_unit", player, [objNull]]];

if (isNull _unit) exitWith {};

private _cards = ["TC2_Card_Red", "TC2_Card_Blue", "TC2_Card_Gold", "TC2_CAC_Card"];

private _give = switch (toUpper _what) do {
    case "RED":    {"TC2_Card_Red"};
    case "BLUE":   {"TC2_Card_Blue"};
    case "GOLD":   {"TC2_Card_Gold"};
    case "BLACK":  {"TC2_Card_Gold"};
    case "CAC":    {"TC2_CAC_Card"};
    case "TABLET": {"TC2_Tablet"};
    default {""};
};

if !(toUpper _what isEqualTo "TABLET") then {
    {_unit removeItems _x} forEach _cards;
};
if (toUpper _what isEqualTo "NONE") then {
    _unit removeItems "TC2_Tablet";
};

if !(_give isEqualTo "") then {
    _unit addItem _give;
};

[format ["Verildi: %1 (seviye şimdi: %2)", [_give, "yok"] select (_give isEqualTo ""), [_unit] call TC2_fnc_accessCardLevel], "info"] call TC2_fnc_notify;
