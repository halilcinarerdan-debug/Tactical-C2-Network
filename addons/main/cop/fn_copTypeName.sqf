/*
    Fonksiyon: TC2_fnc_copTypeName
    Çalışma yeri: Her makine (saf fonksiyon)

    İşaret türü kodunu oyuncuya gösterilecek ada çevirir (katalog: copTypeCatalog).

    Parametreler:
        0: tür kodu <STRING>  (örn. "INF", "ART", "MINE")

    Dönüş: <STRING>
*/

params [["_type", "", [""]]];

([_type] call TC2_fnc_copTypeInfo) select 0
