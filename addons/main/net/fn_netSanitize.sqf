/*
    Fonksiyon: TC2_fnc_netSanitize
    Çalışma yeri: Her makine (saf fonksiyon)

    Kullanıcı metnini structured text'e koymadan önce temizler: '<', '>', '&' ve satır sonu/sekme
    karakterlerini atar (markup enjeksiyonu / ekran bozma önlemi) ve uzunluğu sınırlar.

    Parametreler:
        0: metin <STRING>
        1: azami uzunluk <NUMBER> (varsayılan 120)

    Dönüş: <STRING>
*/

params [["_text", "", [""]], ["_max", 120, [0]]];

private _clean = toString ((toArray _text) select {!(_x in [60, 62, 38, 9, 10, 13])});

_clean select [0, _max min (count _clean)]
