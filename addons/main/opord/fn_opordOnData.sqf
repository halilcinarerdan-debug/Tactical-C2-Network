/*
    Fonksiyon: TC2_fnc_opordOnData
    Çalışma yeri: İSTEMCİ (sunucu opordPoll'e yanıt olarak gönderir)

    OPORD verisini saklar ve ekranı günceller. Gelen bölümler zaten kullanıcının seviyesine göre sunucuda süzülmüştür.

    Parametreler:
        0: kod <STRING>  "OK" | "EMPTY" | erişim ret nedeni
        1: seviye <NUMBER>
        2: üst bilgi <ARRAY>  [başlık, DTG, etiket, sürüm, yayımlayan]
        3: görünür bölümler <ARRAY>  [[anahtar, başlık, seviye, metin]]
        4: gizli bölümler <ARRAY>    [[anahtar, başlık, gereken seviye]]  (metin YOK)
        5: onay sayısı <NUMBER>
        6: kendi onayım var mı <BOOL>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_level", 1, [0]], ["_header", [], [[]]], ["_visible", [], [[]]], ["_hidden", [], [[]]], ["_ackCount", 0, [0]], ["_mine", false, [false]]];

missionNamespace setVariable ["TC2_opord_data", [_code, _level, _header, _visible, _hidden, _ackCount, _mine]];

call TC2_fnc_opordUiUpdate;
