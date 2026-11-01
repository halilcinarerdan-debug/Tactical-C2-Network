/*
    Fonksiyon: TC2_fnc_moduleJtac
    Çalışma yeri: Modül objesinin YEREL olduğu makine (Zeus'ta genelde Zeus'un istemcisi; Eden'de sunucu).
                  Modül isGlobal = 1 olduğundan fonksiyon her makinede çağrılır; `local _logic` ile yalnızca biri çalışır.

    "JTAC Ata / Kaldır" modülü.
      ZEUS:  modülü bir birimin ÜZERİNE koy. O birim JTAC değilse JTAC yapılır, JTAC ise yetkisi kaldırılır (aç/kapa).
             Modül yerleştirildikten kısa süre sonra (bağlanma/replikasyon için 0.5 sn) hedef bulunur:
             önce modüle bağlı obje (attachedTo), yoksa modülün 5 m çevresindeki en yakın asker.
      EDEN:  modülü birimlere BAĞLA (sync). Bağlı tüm askerler oyun başında JTAC olur (yalnızca atama).
    Karar ve yazma SUNUCUDADIR (TC2_fnc_jtacSet); Zeus istemcisi yalnızca istek gönderir.

    Parametreler (BIS modül standardı):
        0: modül <OBJECT>
        1: bağlı (sync) objeler <ARRAY>
        2: etkin mi <BOOL>

    Dönüş: yok
*/

params [["_logic", objNull, [objNull]], ["_units", [], [[]]], ["_activated", true, [true]]];

if (isNull _logic || {!_activated} || {!local _logic}) exitWith {};

// EDEN: bağlı askerler JTAC olur.
private _synced = _units select {_x isKindOf "CAManBase"};
if (!(_synced isEqualTo [])) exitWith {
    {
        if (isServer) then {[_x, true] call TC2_fnc_jtacSet} else {[_x, true] remoteExecCall ["TC2_fnc_jtacSet", 2]};
    } forEach _synced;
    deleteVehicle _logic;
};

// ZEUS: hedefi biraz sonra bul (bağlanma tamamlansın).
[{
    params ["_logic"];
    if (isNull _logic) exitWith {};

    private _unit = attachedTo _logic;
    if (isNull _unit || {!(_unit isKindOf "CAManBase")}) then {
        _unit = (nearestObjects [getPosATL _logic, ["CAManBase"], 5]) param [0, objNull];
    };

    deleteVehicle _logic;

    if (isNull _unit) exitWith {
        ["Modülü bir birimin ÜZERİNE koyun.", "error"] call TC2_fnc_notify;
    };

    private _new = !([_unit] call TC2_fnc_isJtac);

    if (isServer) then {
        [_unit, _new] call TC2_fnc_jtacSet;
    } else {
        [_unit, _new] remoteExecCall ["TC2_fnc_jtacSet", 2];
    };
}, [_logic], 0.5] call CBA_fnc_waitAndExecute;
