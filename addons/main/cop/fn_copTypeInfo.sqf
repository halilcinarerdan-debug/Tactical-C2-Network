/*
    Fonksiyon: TC2_fnc_copTypeInfo
    Çalışma yeri: Her makine (saf fonksiyon)

    Bir işaret türü kodunun bilgisi (copTypeCatalog'dan). Bilinmeyen kod "BİLİNMEYEN TEMAS" gibi davranmaz: ad "İŞARET", simge o_unknown.
    Tehlike türleri (MINE, AMBUSH) turuncu, düşman birlikleri kırmızı çizilir.

    Parametreler:
        0: tür kodu <STRING>

    Dönüş: [ad, simge yolu, simge boyutu, renk, geçerli mi] <ARRAY>
*/

params [["_type", "", [""]]];

private _result = ["İŞARET", "\A3\ui_f\data\map\markers\nato\o_unknown.paa", 26, [1, 0.1, 0.1, 1], false];

{
    {
        if ((_x select 0) isEqualTo _type) exitWith {
            _result = [_x select 1, _x select 2, _x select 3, [[1, 0.1, 0.1, 1], [1, 0.6, 0.1, 1]] select (_type in ["MINE", "AMBUSH"]), true];
        };
    } forEach (_x select 1);
} forEach ([] call TC2_fnc_copTypeCatalog);

_result
