/*
    Fonksiyon: TC2_fnc_opordVar
    Çalışma yeri: SADECE SUNUCU (saf)

    TARAF AYRIMI: belge (OPORD / WARNO) taraf başına AYRI bir sunucu değişkeninde tutulur; BLUFOR emri OPFOR'a görünmez.
    Dönüş: "TC2_opord_WEST", "TC2_warno_EAST", "TC2_opord_GUER" ...

    Parametreler:
        0: belge türü <STRING>  "OPORD" | "WARNO"
        1: taraf <SIDE>

    Dönüş: <STRING>
*/

params [["_docType", "OPORD", [""]], ["_side", west, [west]]];

format ["TC2_%1_%2", ["opord", "warno"] select (_docType isEqualTo "WARNO"), str _side]
