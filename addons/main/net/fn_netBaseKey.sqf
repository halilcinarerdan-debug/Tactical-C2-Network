/*
    Fonksiyon: TC2_fnc_netBaseKey
    Çalışma yeri: SADECE SUNUCU (saf)

    TARAF AYRIMI: telsiz tipine askerin tarafını ekler ("ACRE_PRC343|WEST"). Sunucuda ağ (aynı tip + kanal + menzil) karşılaştırması bu anahtarla
    yapıldığı için BLUFOR / OPFOR / INDFOR AYNI telsiz tipi ve kanalında olsa bile birbirlerinin harita, işaret, mesaj, rapor, CAS / MEDEVAC / topçu
    verisini GÖRMEZ. Menzil tablosu araması tarafı yok sayar (netRangeOf).

    Parametreler:
        0: telsiz tipi <STRING>  (boş = telsiz yok; boş döner)
        1: birim <OBJECT>

    Dönüş: <STRING>
*/

params [["_base", "", [""]], ["_unit", objNull, [objNull]]];

if (_base isEqualTo "" || {isNull _unit}) exitWith {_base};

format ["%1|%2", (_base splitString "|") select 0, str (side (group _unit))]
