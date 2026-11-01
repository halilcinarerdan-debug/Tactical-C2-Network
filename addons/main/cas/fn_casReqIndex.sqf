/*
    Fonksiyon: TC2_fnc_casReqIndex
    Çalışma yeri: SADECE SUNUCU

    CAS talebi kayıtları (TC2_cas_requests). Her kayıt:
        0 id   1 JTAC netId   2 JTAC birimi   3 pilot netId   4 pilot birimi   5 form verisi   6 platform
        7 durum ("SENT" | "READBACK_OK" | "READBACK_FAIL" | "ABORTED")   8 son geri okuma sonuçları   9 oluşma zamanı
        10 telsiz tipi   11 kanal   12 JTAC çağrı adı   13 pilot çağrı adı   14 simüle pilot mu   15 simüle pilot yanlış mı okusun

    Eski kayıtları (30 dk) siler, sonra verilen id'nin sırasını verir (-1 = yok).

    Parametreler:
        0: talep id <NUMBER>

    Dönüş: sıra <NUMBER>
*/

params [["_id", -1, [0]]];

private _now = diag_tickTime;
private _requests = (missionNamespace getVariable ["TC2_cas_requests", []]) select {(_now - (_x select 9)) < 1800};
missionNamespace setVariable ["TC2_cas_requests", _requests];

private _index = -1;
{
    if ((_x select 0) == _id) exitWith {_index = _forEachIndex};
} forEach _requests;

_index
