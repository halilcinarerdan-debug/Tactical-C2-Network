/*
    Fonksiyon: TC2_fnc_debugInfo
    Çalışma yeri: Her makine (debug konsolu "Local Exec" veya "Server Exec" ile)

    Tek başına test ederken "neden çalışmıyor?" sorusunun cevabını verir:
      - makine rolü (sunucu mu, istemci mi, dedicated mı)
      - kimlik kartı ayarı ve aday sınıfların gerçekten var olup olmadığı
      - birimin envanteri ve kartı olup olmadığı
      - yakındaki terminaller
    Çıktı: systemChat + RPT ("[TC2][DEBUG]") + panoya kopyalanır (bana yapıştırabilirsin).

    Parametreler:
        0: birim <OBJECT> (varsayılan: player)

    Dönüş: satırlar <ARRAY of STRING>
*/

params [["_unit", player, [objNull]]];

private _lines = [];

_lines pushBack format ["Rol: isServer=%1 | hasInterface=%2 | isDedicated=%3 | isMultiplayer=%4", isServer, hasInterface, isDedicated, isMultiplayer];
_lines pushBack format ["clientOwner=%1 | owner(birim)=%2", clientOwner, if (isNull _unit) then {"yok"} else {owner _unit}];

// Kimlik kartı ayarı ve adayların CfgWeapons / CfgVehicles'ta var olup olmadığı
_lines pushBack format ["Ayar TC2_access_cardClasses = '%1'", missionNamespace getVariable ["TC2_access_cardClasses", "(ayar yok)"]];
{
    _lines pushBack format ["  aday '%1': CfgWeapons=%2 | CfgVehicles=%3", _x, isClass (configFile >> "CfgWeapons" >> _x), isClass (configFile >> "CfgVehicles" >> _x)];
} forEach ([] call TC2_fnc_accessGetCardClasses);

if (!isNull _unit) then {
    _lines pushBack format ["items: %1", items _unit];
    _lines pushBack format ["assignedItems: %1", assignedItems _unit];
    _lines pushBack format ["Kart var mı (accessHasCard): %1", [_unit] call TC2_fnc_accessHasCard];

    private _terminals = nearestObjects [_unit, ["TC2_Terminal_F"], 15];
    _lines pushBack format ["15 m içindeki terminal sayısı: %1", count _terminals];
    {
        _lines pushBack format ["  terminal '%1' | mesafe %2 m", [_x] call TC2_fnc_terminalGetId, (round ((_unit distance _x) * 10)) / 10];
    } forEach _terminals;
};

{
    diag_log ("[TC2][DEBUG] " + _x);
    if (hasInterface) then {systemChat _x};
} forEach _lines;

copyToClipboard (_lines joinString endl);

_lines
