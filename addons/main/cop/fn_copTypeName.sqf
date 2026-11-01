/*
    Fonksiyon: TC2_fnc_copTypeName
    Çalışma yeri: Her makine (saf fonksiyon)

    İşaret türü kodunu oyuncuya gösterilecek ada çevirir. Yeni türler (araç, topçu vb.) buraya eklenir.

    Parametreler:
        0: tür kodu <STRING>  ("INF")

    Dönüş: <STRING>
*/

params [["_type", "", [""]]];

switch (_type) do {
    case "INF": {"DÜŞMAN PİYADE"};
    default {"İŞARET"};
};
