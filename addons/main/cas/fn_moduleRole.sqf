/*
    Fonksiyon: TC2_fnc_moduleRole
    Çalışma yeri: Modül objesinin YEREL olduğu makine (Zeus'ta genelde Zeus'un istemcisi; Eden'de sunucu).
                  Modüller isGlobal = 1 olduğundan fonksiyon her makinede çağrılır; `local _logic` ile yalnızca biri çalışır.

    "Rol Ata / Kaldır" modülleri (JTAC, Gözlemci, FDC). Hangi rol olduğu modül sınıfının `tc2_role` özelliğinden okunur.
      ZEUS:  modülü bir birimin ÜZERİNE koy. Birimde o rol yoksa verilir, varsa kaldırılır (aç/kapa).
             Hedef: önce modüle bağlı obje (attachedTo), yoksa modülün 5 m çevresindeki en yakın asker (0.5 sn sonra, bağlanma için).
      EDEN:  modülü birimlere BAĞLA (sync). Bağlı tüm askerlere oyun başında rol verilir (yalnızca atama).
    Karar ve yazma SUNUCUDADIR (TC2_fnc_roleSet); Zeus istemcisi yalnızca istek gönderir.

    Parametreler (BIS modül standardı):
        0: modül <OBJECT>
        1: bağlı (sync) objeler <ARRAY>
        2: etkin mi <BOOL>

    Dönüş: yok
*/

params [["_logic", objNull, [objNull]], ["_units", [], [[]]], ["_activated", true, [true]]];

if (isNull _logic || {!_activated} || {!local _logic}) exitWith {};

private _role = getText (configFile >> "CfgVehicles" >> typeOf _logic >> "tc2_role");
if (_role isEqualTo "") exitWith {deleteVehicle _logic};

// EDEN: bağlı askerler role atanır.
private _synced = _units select {_x isKindOf "CAManBase"};
if (!(_synced isEqualTo [])) exitWith {
    {
        if (isServer) then {[_x, _role, true] call TC2_fnc_roleSet} else {[_x, _role, true] remoteExecCall ["TC2_fnc_roleSet", 2]};
    } forEach _synced;
    deleteVehicle _logic;
};

// ZEUS: hedefi biraz sonra bul (bağlanma tamamlansın).
[{
    params ["_logic", "_role"];
    if (isNull _logic) exitWith {};

    private _unit = attachedTo _logic;
    if (isNull _unit || {!(_unit isKindOf "CAManBase")}) then {
        _unit = (nearestObjects [getPosATL _logic, ["CAManBase"], 5]) param [0, objNull];
    };

    deleteVehicle _logic;

    if (isNull _unit) exitWith {
        ["Modülü bir birimin ÜZERİNE koyun.", "error"] call TC2_fnc_notify;
    };

    private _new = !([_unit, _role] call TC2_fnc_hasRole);

    if (isServer) then {
        [_unit, _role, _new] call TC2_fnc_roleSet;
    } else {
        [_unit, _role, _new] remoteExecCall ["TC2_fnc_roleSet", 2];
    };
}, [_logic, _role], 0.5] call CBA_fnc_waitAndExecute;
