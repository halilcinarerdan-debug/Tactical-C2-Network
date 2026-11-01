/*
    Fonksiyon: TC2_fnc_copPush
    Çalışma yeri: SADECE SUNUCU

    Bir ağdaki (tip + kanal) tüm saha birimlerinin MicroDAGR özetini yeniden hesaplar (işaret eklendi/silindi).
    Değişenlere anında gönderilir; 10 sn'lik rapor beklenmez.

    Parametreler:
        0: telsiz tipi <STRING>
        1: kanal <NUMBER>

    Dönüş: yok
*/

params [["_base", "", [""]], ["_channel", -1, [0]]];

{
    [_x] call TC2_fnc_copSyncUnit;
} forEach ((missionNamespace getVariable ["TC2_cop_field", []]) select {((_x select 3) isEqualTo _base) && {(_x select 4) == _channel}});
