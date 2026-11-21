/*
    Fonksiyon: TC2_fnc_netBaseName
    Çalışma yeri: Her makine (saf)

    Taraf eki taşıyan ağ anahtarından ("ACRE_PRC343|WEST") yalnızca telsiz tipini verir (ekranda göstermek için).

    Parametreler:
        0: ağ anahtarı <STRING>

    Dönüş: <STRING>
*/

params [["_key", "", [""]]];

if (_key isEqualTo "") exitWith {""};

(_key splitString "|") select 0
