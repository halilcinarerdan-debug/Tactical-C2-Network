/*
    Fonksiyon: TC2_fnc_canWriteFires
    Çalışma yeri: Her makine (saf fonksiyon). Sunucu bununla KARAR verir.

    9-Line (CAS) ya da CFF (topçu) YAZMA yetkisi:
      - ilgili rol: CAS için JTAC; topçu için gözlemci ya da JTAC (rol / Zeus / rol açıklaması / sınıf),
      - ya da MASA BAŞINDA Level 2 ve üstü kart/kadro (Mavi kart yazar; CBA "Masa başında Mavi+ kart 9-Line / CFF yazabilsin" açıksa).
    Saha cihazında yalnızca rol geçerlidir (doktrin: terminal saldırı kontrolü JTAC'ındır; masa başı, JTAC adına talebi hazırlayan ateş destek hücresidir).

    Parametreler:
        0: asker <OBJECT>
        1: terminal / saha cihazı <OBJECT>
        2: tür <STRING>  "CAS" | "ARTY"

    Dönüş: <BOOL>
*/

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_kind", "CAS", [""]]];

if (isNull _unit) exitWith {false};

private _byRole = if (_kind isEqualTo "CAS") then {
    [_unit, "JTAC"] call TC2_fnc_hasRole
} else {
    [_unit, "OBSERVER"] call TC2_fnc_hasRole || {[_unit, "JTAC"] call TC2_fnc_hasRole}
};
if (_byRole) exitWith {true};

(!(_terminal isEqualTo _unit))
&& {missionNamespace getVariable ["TC2_desk_fires", true]}
&& {([_unit, _terminal] call TC2_fnc_accessLevel) >= 2}
