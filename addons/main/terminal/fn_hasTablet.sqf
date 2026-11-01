/*
    Fonksiyon: TC2_fnc_hasTablet
    Çalışma yeri: Her makine (saf fonksiyon). Sunucu bununla KARAR verir.

    "Tablet kuralı": uçak/helikopter mürettebatı DIŞINDAKİ herkes terminale bilgi GÖNDERMEK (konum/durum raporu, mesaj, işaret, formlar)
    ve terminalden bilgi ALMAK (haritadaki dostlar, mesajlar, DAGR işaretleri, formların yanıtları) için envanterinde saha tableti taşımalıdır.
    Hava aracında (Air sınıfı araç) olanlar tablet istemez: araç telsizi / ACE self menüsünü kullanırlar.
    CBA "Saha cihazı eşyası" boşsa tablet şartı yoktur (herkes geçer). Masa başı terminal kullanıcısı tablet istemez (PC'nin başındadır).

    Parametreler:
        0: asker <OBJECT>

    Dönüş: <BOOL>
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {false};
if ((vehicle _unit) isKindOf "Air") exitWith {true};

private _item = missionNamespace getVariable ["TC2_field_deviceItem", "TC2_Tablet"];
if (_item isEqualTo "") exitWith {true};

(toLower _item) in ((items _unit + assignedItems _unit) apply {toLower _x})
