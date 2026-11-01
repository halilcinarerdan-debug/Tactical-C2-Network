/*
    Fonksiyon: TC2_fnc_netRangeOf
    Çalışma yeri: Her makine (saf fonksiyon)

    Telsiz tipinin menzilini (metre) verir. Değerler CBA ayarı "TC2_net_ranges" tablosundan okunur:
        "ACRE_PRC343=500;ACRE_PRC148=5000;...;default=3000"
    Tabloda yoksa "default" anahtarı, o da yoksa 3000 m kullanılır.

    NOT: Bu, ACRE2'nin arazi/yayılım modeli DEĞİL; telsiz tipine bağlı sabit menzil tablosudur
    (ACRE'nin sinyal hesabı genel API değildir ve dış eklenti üzerinden asenkron çalışır).

    Parametreler:
        0: telsiz taban sınıfı <STRING>  örn. "ACRE_PRC152"

    Dönüş: menzil, metre <NUMBER>
*/

params [["_class", "", [""]]];

private _default = 3000;
private _result = -1;

{
    private _pair = _x splitString "=: ";
    if (count _pair == 2) then {
        private _key = toLower (_pair select 0);
        private _value = parseNumber (_pair select 1);
        if (_key == "default") then {_default = _value};
        if (_key == toLower _class) then {_result = _value};
    };
} forEach ((missionNamespace getVariable ["TC2_net_ranges", ""]) splitString ";");

if (_result < 0) then {_default} else {_result}
