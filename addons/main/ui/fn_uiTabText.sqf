/*
    Fonksiyon: TC2_fnc_uiTabText
    Çalışma yeri: İstemci (saf fonksiyon)

    Sekme içeriğini structured text olarak üretir. Şu an yalnızca ANA sekmesi gerçek veri gösterir;
    diğerleri hangi aşamada geleceğini söyleyen kısa bir not içerir. Sonraki aşamalar yalnızca
    ilgili case bloğunu doldurur.

    Parametreler:
        0: sekme sırası <NUMBER>
        1: terminal <OBJECT>
        2: kullanıcı birimi <OBJECT>

    Dönüş: <TEXT>
*/

params [["_index", 0, [0]], ["_terminal", objNull, [objNull]], ["_unit", objNull, [objNull]]];

private _dim = "#1f9930";
private _main = "#40ff59";

private _body = switch (_index) do {
    case 0: {
        format [
            "<t color='%1'>KULLANICI</t>   %3 %4<br/><t color='%1'>BİRLİK</t>      %5<br/><t color='%1'>TERMİNAL</t>   %6<br/><t color='%1'>KİMLİK</t>      DOĞRULANDI (CAC)",
            _dim,
            _main,
            rank _unit,
            name _unit,
            groupId (group _unit),
            [_terminal] call TC2_fnc_terminalGetId
        ]
    };
    case 1: {""};  // HARİTA sekmesi: içerik harita kontrolüdür (copUiBuild)
    case 2: {""};  // CAS sekmesi: içerik 9-Line formudur (casUiBuild)
    case 3: {""};  // TOPÇU sekmesi: gözlemci CFF formu (artyObsBuild)
    case 4: {""};  // FDC sekmesi: FDC operatörü ekranı (artyFdcBuild)
    case 5: {""};  // OPORD sekmesi: yetki seviyeli belge (opordBuild)
    case 6: {"INTSUM (istihbarat özeti) belgeleri (yetki seviyesine göre).<br/><br/>Aşama 6'nın devamında eklenecek."};
    case 7: {"Lojistik talepleri.<br/><br/>Aşama 6'nın devamında eklenecek."};
    case 8: {"UAV: yetkili İHA listesi, bağlantı durumu, yayın isteği.<br/><br/>Ağ (Aşama 3) kurulduktan sonra eklenecek. Bkz. docs/UAV_ENTEGRASYON.md"};
    default {""};
};

parseText format ["<t size='1.1' color='%1'>%2</t>", _main, _body]
