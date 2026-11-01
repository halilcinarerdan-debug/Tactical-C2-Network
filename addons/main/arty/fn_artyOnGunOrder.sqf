/*
    Fonksiyon: TC2_fnc_artyOnGunOrder
    Çalışma yeri: İSTEMCİ (oyuncu top mürettebatı; FDC'nin ateş emri)

    Oyuncu mürettebatlı bataryaya ATEŞ EMRİ gösterir: hedef grid, azimut (mil), mesafe, mühimmat, mermi sayısı.
    Topçu atış verisini kendi araçlarıyla (ACE tabloları / vanilla artillery computer) uygular.

    Parametreler:
        0: emir metni <STRING>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_text", "", [""]]];

if (isClass (configFile >> "CfgSounds" >> "FD_Timer_F")) then {playSound "FD_Timer_F"};
[_text, "info"] call TC2_fnc_notify;
systemChat _text;
