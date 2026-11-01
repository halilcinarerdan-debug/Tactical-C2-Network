/*
    Fonksiyon: TC2_fnc_hasRole
    Çalışma yeri: Her makine (saf fonksiyon). Yetki kararı SUNUCUDA bununla verilir.

    Bu asker verilen role sahip mi? Roller: "JTAC", "OBSERVER" (gözlemci: FO / JFO / FIST), "FDC" (ateş yönetim merkezi operatörü).
    Öncelik sırası:
      1. AÇIK ATAMA: objedeki değişken (TC2_jtac / TC2_observer / TC2_fdc) true veya false. Zeus modülleri ve Eden init buna yazar.
         false = bilerek kaldırılmış; sınıf/rol açıklaması o role işaret etse bile SAYILMAZ.
      2. EDEN ROL AÇIKLAMASI (Attributes > Role Description) şu kelimelerden birini içerirse:
           JTAC: jtac, fac        OBSERVER: fo, jfo, fist, observer, gözlemci        FDC: fdc, fdo
         (büyük/küçük harf önemsiz; kelime olarak aranır, "factory" gibi kelimeler eşleşmez)
      3. SINIF listesi (CBA ayarları: JTAC sınıfları / Gözlemci sınıfları / FDC sınıfları).
    ACE'in kendi bir JTAC/gözlemci/FDC rolü yoktur; bu üç yol görevlerde yaygın olanlardır.

    Parametreler:
        0: asker <OBJECT>
        1: rol <STRING>  "JTAC" | "OBSERVER" | "FDC"

    Dönüş: <BOOL>
*/

params [["_unit", objNull, [objNull]], ["_role", "", [""]]];

if (isNull _unit) exitWith {false};

_role = toUpper _role;

private _variable = switch (_role) do {
    case "JTAC":     {"TC2_jtac"};
    case "OBSERVER": {"TC2_observer"};
    case "FDC":      {"TC2_fdc"};
    default {""};
};
if (_variable isEqualTo "") exitWith {false};

private _explicit = _unit getVariable [_variable, objNull];
if (_explicit isEqualType true) exitWith {_explicit};

private _names = switch (_role) do {
    case "JTAC":     {["jtac", "fac"]};
    case "OBSERVER": {["fo", "jfo", "fist", "observer", "gözlemci", "gozlemci"]};
    default          {["fdc", "fdo"]};
};
private _tokens = (toLower (roleDescription _unit)) splitString " ()[]/-_,.:;";
if (count (_names arrayIntersect _tokens) > 0) exitWith {true};

private _setting = switch (_role) do {
    case "JTAC":     {"TC2_cas_jtacClasses"};
    case "OBSERVER": {"TC2_arty_observerClasses"};
    default          {"TC2_arty_fdcClasses"};
};
private _classes = ((missionNamespace getVariable [_setting, ""]) splitString ";, ") apply {toLower _x};

(toLower (typeOf _unit)) in _classes
