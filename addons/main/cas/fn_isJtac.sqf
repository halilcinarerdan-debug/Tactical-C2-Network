/*
    Fonksiyon: TC2_fnc_isJtac
    Çalışma yeri: Her makine (saf fonksiyon)

    Bu asker JTAC mi? Kısayol: [unit, "JTAC"] call TC2_fnc_hasRole. Kuralların ayrıntısı hasRole'dadır.

    Parametreler:
        0: asker <OBJECT>

    Dönüş: <BOOL>
*/

params [["_unit", objNull, [objNull]]];

[_unit, "JTAC"] call TC2_fnc_hasRole
