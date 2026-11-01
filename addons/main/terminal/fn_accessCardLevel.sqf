/*
    Fonksiyon: TC2_fnc_accessCardLevel
    Çalışma yeri: Her makine (saf fonksiyon). Sunucu bununla KARAR verir.

    Askerin taşıdığı en yüksek SEVİYE KARTI (üniforma/yelek/çanta + atanmış eşyalar):
      Siyah-Altın (TC2_Card_Gold) = 3,   Mavi (TC2_Card_Blue) = 2,
      Kırmızı (TC2_Card_Red), eski TC2_CAC_Card ve CBA'daki ek kart sınıfları = 1,   kart yok = 0.

    Parametreler:
        0: asker <OBJECT>

    Dönüş: 0-3 <NUMBER>
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {0};

private _have = (items _unit + assignedItems _unit) apply {toLower _x};

if ("tc2_card_gold" in _have) exitWith {3};
if ("tc2_card_blue" in _have) exitWith {2};
if (count (([] call TC2_fnc_accessGetCardClasses) arrayIntersect _have) > 0) exitWith {1};

0
