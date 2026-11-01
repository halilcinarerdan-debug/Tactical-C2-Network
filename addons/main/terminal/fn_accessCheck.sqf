/*
    Fonksiyon: TC2_fnc_accessCheck
    Çalışma yeri: SUNUCU (kararı veren yer). Saf fonksiyon: yalnızca okur, hiçbir şeyi değiştirmez;
                  bu yüzden debug konsolunda AI birimleriyle doğrudan denenebilir.

    Bir birimin bir terminale girmesine izin verilir mi? Kontroller sırayla yapılır, ilk başarısızlıkta durur:

        1. parametreler geçerli mi                  -> BAD_PARAMS
        2. terminal sistemi açık mı (CBA ayarı)     -> DISABLED
        3. obje gerçekten TC2 terminali mi          -> NOT_TERMINAL   (SAHA CİHAZI modunda bu adım yerine: FIELD_DISABLED)
        4. birim hayatta mı                         -> DEAD
        5. birim bilinçli mi (ACE/vanilla)          -> UNCONSCIOUS
        6. birim terminale yeterince yakın mı       -> TOO_FAR
        7. birimde kimlik kartı var mı              -> NO_CARD

    Mesafe sınırı (5 m): ACE menüsü 2.5 m'de açılır, ilerleme çubuğu sırasında 1-2 adım atılabilir ve
    ağ gecikmesi payı bırakılır. Sunucuda kontrol, istemcinin yalan söylemesine karşıdır.

    Parametreler:
        0: terminal <OBJECT>
        1: birim <OBJECT>

    Dönüş: [izin verildi mi <BOOL>, neden kodu <STRING>]   (başarıda "OK")
*/

params [["_terminal", objNull, [objNull]], ["_unit", objNull, [objNull]]];

private _maxDistance = 5;

if (isNull _terminal || {isNull _unit}) exitWith {[false, "BAD_PARAMS"]};

if !(missionNamespace getVariable ["TC2_terminal_enabled", true]) exitWith {[false, "DISABLED"]};

// SAHA CİHAZI modu: "terminal" olarak birimin KENDİSİ verilir (laptop gerekmez). Saha cihazında mesafe ve
// (varsayılan olarak) kart kontrolü yoktur; telsiz ağı ve rol kontrolleri (JTAC / gözlemci) diğer katmanlarda sürer.
// İsteğe bağlı sıkılaştırma (CBA): saha cihazı eşyası, kimlik kartı.
private _fieldMode = _terminal isEqualTo _unit;

if (_fieldMode && {!(missionNamespace getVariable ["TC2_field_enabled", true])}) exitWith {[false, "FIELD_DISABLED"]};
if (!_fieldMode && {!(_terminal isKindOf "TC2_Terminal_F")}) exitWith {[false, "NOT_TERMINAL"]};

if !(alive _unit) exitWith {[false, "DEAD"]};

if ((_unit getVariable ["ACE_isUnconscious", false]) || {lifeState _unit == "INCAPACITATED"}) exitWith {[false, "UNCONSCIOUS"]};

if (_fieldMode) exitWith {
    // Tablet kuralı (hasTablet): hava aracı mürettebatı muaf; CBA eşya boşsa şart yok.
    if !([_unit] call TC2_fnc_hasTablet) exitWith {[false, "NO_DEVICE"]};
    if ((missionNamespace getVariable ["TC2_field_requireCard", false]) && {!([_unit] call TC2_fnc_accessHasCard)}) exitWith {[false, "NO_CARD"]};

    [true, "OK"]
};

if ((_unit distance _terminal) > _maxDistance) exitWith {[false, "TOO_FAR"]};

if !([_unit] call TC2_fnc_accessHasCard) exitWith {[false, "NO_CARD"]};

[true, "OK"]
