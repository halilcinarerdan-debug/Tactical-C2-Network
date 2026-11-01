/*
    Fonksiyon: TC2_fnc_accessLevel
    Çalışma yeri: Her makine (saf fonksiyon). Belge yetkisi kararı SUNUCUDA bununla verilir.

    Bir kullanıcının BU CİHAZDAKİ belge seviyesi (1-3):
      MASA BAŞI TERMİNAL:  max(kart seviyesi, kadro seviyesi)
          kart:   Kırmızı 1 / Mavi 2 / Siyah-Altın 3
          kadro:  CO (Bölük Komutanı) 3, S2 (İstihbarat) 3, S4 (Lojistik) = CBA "TC2_s4_level" (2 ya da 3)
      SAHA CİHAZI (tablet):  userLevel (rütbe / grup lideri / rol) ve EN FAZLA 2.
          Level 3 (gizli) belgeler sahada okunamaz; yalnızca masa başında (OPSEC).
    AÇIK ATAMA: objedeki `TC2_level` (1-3) her ikisinde de geçerlidir (sahada yine 2 ile sınırlı).

    Parametreler:
        0: asker <OBJECT>
        1: terminal / saha cihazı <OBJECT>  (saha cihazında birimin kendisi)

    Dönüş: seviye <NUMBER> (1-3)
*/

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]]];

if (isNull _unit) exitWith {1};

private _field = _terminal isEqualTo _unit;
private _explicit = _unit getVariable ["TC2_level", objNull];

private _level = 1;

if (_explicit isEqualType 0) then {
    _level = ((round _explicit) max 1) min 3;
} else {
    if (_field) then {
        _level = [_unit] call TC2_fnc_userLevel;
    } else {
        private _role = 0;
        if ([_unit, "CO"] call TC2_fnc_hasRole || {[_unit, "S2"] call TC2_fnc_hasRole}) then {_role = 3};
        if (_role < 3 && {[_unit, "S4"] call TC2_fnc_hasRole}) then {_role = (missionNamespace getVariable ["TC2_s4_level", 2]) max 2 min 3};
        _level = ((([_unit] call TC2_fnc_accessCardLevel) max _role) max 1) min 3;
    };
};

if (_field) then {_level = _level min 2};

_level
