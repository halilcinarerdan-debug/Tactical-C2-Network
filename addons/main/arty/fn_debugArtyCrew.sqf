/*
    Fonksiyon: TC2_fnc_debugArtyCrew
    Çalışma yeri: SADECE SUNUCU (debug konsolunda "Server Exec"; host'ta "Local Exec" da olur)

    TEST YARDIMCISI: AI topçu desteklenmez; oyuncu mürettebatlı batarya olmadan FDC akışını denemek için bir topa "simüle mürettebat" işareti koyar.
    Böyle bir top kullanılabilir batarya sayılır; FDC KABUL edince ateş emri olay günlüğüne düşer ve FDC SHOT / SPLASH / ROUNDS COMPLETE'i elle girer.
    Top mürettebatsız olsa da çalışır (taraf, topun sınıfından alınır).

    Parametreler:
        0: top / havan <OBJECT>
        1: aç/kapat <BOOL>  (varsayılan true)

    Dönüş: yok

    Örnek: [cursorObject] call TC2_fnc_debugArtyCrew;
*/

if (!isServer) exitWith {};

params [["_gun", objNull, [objNull]], ["_enable", true, [true]]];

if (isNull _gun) exitWith {};

_gun setVariable ["TC2_arty_simCrew", _enable, true];
diag_log format ["[TC2][ARTY] debugArtyCrew %1 top=%2", ["KALDIRILDI", "EKLENDI"] select _enable, typeOf _gun];
