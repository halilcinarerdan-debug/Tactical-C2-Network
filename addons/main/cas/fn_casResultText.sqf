/*
    Fonksiyon: TC2_fnc_casResultText
    Çalışma yeri: İstemci (saf fonksiyon)

    Geri okuma sonuçlarını renkli satırlar olarak verir (structured text): doğru satır yeşil TAMAM,
    yanlış satır kırmızı HATA + doğru değer. JTAC ve pilot aynı sonucu görür.

    Parametreler:
        0: sonuçlar <ARRAY>  [[anahtar, etiket, doğru mu, doğru değer]]

    Dönüş: <STRING> (structured text biçimi)
*/

params [["_results", [], [[]]]];

if (_results isEqualTo []) exitWith {""};

(_results apply {
    _x params ["", "_label", "_ok", "_expected"];
    if (_ok) then {
        format ["<t color='#40ff59'>TAMAM</t>  %1", _label]
    } else {
        format ["<t color='#ff5555'>HATA</t>  %1  -  doğru: <t color='#ffffff'>%2</t>", _label, _expected]
    }
}) joinString "<br/>"
