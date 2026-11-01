/*
    Fonksiyon: TC2_fnc_isJtac
    Çalışma yeri: Her makine (saf fonksiyon). Yetki kararı SUNUCUDA bununla verilir.

    Bu asker JTAC mi? Öncelik sırası:
      1. AÇIK ATAMA: objedeki `TC2_jtac` değişkeni (true / false). Zeus modülü ve Eden init buna yazar. false = bilerek kaldırılmış,
         asker sınıfı/rolü JTAC olsa bile JTAC SAYILMAZ.
      2. EDEN ROL AÇIKLAMASI (Attributes > Role Description): "JTAC" veya "FAC" kelimesi geçiyorsa (büyük/küçük harf önemsiz).
      3. SINIF: CBA ayarındaki JTAC sınıf listesinde (varsayılan: vanilla Recon JTAC sınıfları; mod sınıfları eklenebilir).
    ACE'in kendi bir "JTAC" rolü yoktur; bu yüzden görevlerde yaygın olan bu üç yol desteklenir.

    Parametreler:
        0: asker <OBJECT>

    Dönüş: <BOOL>
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {false};

private _explicit = _unit getVariable ["TC2_jtac", objNull];
if (_explicit isEqualType true) exitWith {_explicit};

private _tokens = (toLower (roleDescription _unit)) splitString " ()[]/-_,.:;";
if ("jtac" in _tokens || {"fac" in _tokens}) exitWith {true};

private _classes = ((missionNamespace getVariable ["TC2_cas_jtacClasses", ""]) splitString ";, ") apply {toLower _x};
(toLower (typeOf _unit)) in _classes
