/*
    Fonksiyon: TC2_fnc_terminalInitActions
    Çalışma yeri: İstemci (terminalPostInit çağırır)

    ACE etkileşim menüsüne (ana etkileşim, Sol Windows tuşu) terminal sınıfı için eylem ekler:

        TC2 Command Terminal
            └─ Terminale Giriş (Kimlik Kartı)

    Eylem SINIFA (TC2_Terminal_F) tek bir kez eklenir. Böylece:
      - Eden'de/Zeus'ta/script ile yaratılan her terminalde otomatik vardır,
      - JIP oyuncular için ek senkronizasyon gerekmez (eylem yerelde, sınıfa bağlı),
      - dekor amaçlı vanilla laptoplar etkilenmez.

    Koşul kodu, menü bu objeye bakarken HER KAREDE çalışır -> yalnızca ucuz kontroller.
    Asıl yetki kararı (kart, mesafe, yaşıyor mu) SUNUCUDA verilir; buradaki koşullar sadece arayüz kolaylığıdır.

    Parametreler: yok
    Dönüş: yok
*/

private _accessAction = [
    "TC2_terminal_access",
    "Terminale Giriş (Kimlik Kartı)",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\intel_ca.paa",
    {
        params ["_target", "_player"];
        [_target, _player] call TC2_fnc_accessRequest;
    },
    {
        params ["_target", "_player"];
        (missionNamespace getVariable ["TC2_terminal_enabled", true])
        && {(missionNamespace getVariable ["TC2_access_pendingId", -1]) < 0}
        && {[_player, _target, []] call ace_common_fnc_canInteractWith}
    },
    {},
    [],
    [0, 0, 0.1],
    2.5
] call ace_interact_menu_fnc_createAction;

["TC2_Terminal_F", 0, ["ACE_MainActions"], _accessAction] call ace_interact_menu_fnc_addActionToClass;
