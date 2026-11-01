/*
    Fonksiyon: TC2_fnc_casPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf, hasInterface kontrolünden sonra)

    Pilot tarafı: ACE self menüsüne "CAS 9-Line" eylemini ekler. Eylem, gelen bir 9-Line varsa görünür ve
    UÇAK İÇİNDE de çalışır (self menü). Tek bir kez, CAManBase sınıfına eklenir (respawn/JIP için ek iş yok).

    Parametreler: yok
    Dönüş: yok
*/

missionNamespace setVariable ["TC2_cas_incoming", []];
missionNamespace setVariable ["TC2_cas_data", [false, [], []]];

private _action = [
    "TC2_cas_incoming",
    "CAS 9-Line",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\target_ca.paa",
    {
        // ACE menüsü kendi diyaloğunu kapatır; yenisini bir sonraki karede aç.
        [{call TC2_fnc_casPilotOpen}] call CBA_fnc_execNextFrame;
    },
    {
        count (missionNamespace getVariable ["TC2_cas_incoming", []]) > 0
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;
