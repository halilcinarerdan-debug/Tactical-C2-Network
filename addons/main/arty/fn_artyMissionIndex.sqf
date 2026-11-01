/*
    Fonksiyon: TC2_fnc_artyMissionIndex
    Çalışma yeri: SADECE SUNUCU

    Atış görevi kayıtları (TC2_arty_missions). Her kayıt:
         0 id               1 gözlemci netId     2 gözlemci birimi    3 gözlemci çağrı adı
         4 FDC netId        5 FDC birimi         6 FDC çağrı adı      7 durum
         8 CFF verisi       9 hedef numarası    10 nişan noktası ASL 11 gözlemci-hedef yönü (mil, -1 = yok)
        12 top netId'leri  13 hacim (top başına) 14 günlük (metin dizisi) 15 oluşma zamanı
        16 telsiz tipi     17 kanal             18 atılan mermi      19 faz ("ADJUST" | "FFE")
        20 beklenen mermi  21 elle (oyuncu bataryası var mı) 22 DANGER CLOSE bildirildi mi  23 batarya etiketi
        24 FDC değişiklikleri (metin)   25 mühimmat şarjörü
    Durumlar: REQUEST (FDC bekliyor) -> READY (AMC: FIRE bekleniyor) -> FIRING -> SPOTTING (adjust: düzeltme bekleniyor)
              -> SURVEILLANCE (FFE bitti: gözetim/EOM) -> EOM; ayrıca REJECTED, CANCELLED.
    Eski kayıtlar (2 saat) silinir. Verilen id'nin sırasını verir (-1 = yok).

    Parametreler:
        0: görev id <NUMBER>

    Dönüş: sıra <NUMBER>
*/

params [["_id", -1, [0]]];

private _now = diag_tickTime;
private _missions = (missionNamespace getVariable ["TC2_arty_missions", []]) select {(_now - (_x select 15)) < 7200};
missionNamespace setVariable ["TC2_arty_missions", _missions];

private _index = -1;
{
    if ((_x select 0) == _id) exitWith {_index = _forEachIndex};
} forEach _missions;

_index
