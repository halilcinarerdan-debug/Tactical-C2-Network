# Aşama 3 — ACRE2 veri ağı ve mesajlaşma testi (tek kişilik)

Aşama 1 ve 2 testleri geçmiş olmalı. Gerekenler: **ACRE2 yüklü**, oyuncuda ACRE telsizi (ör. `ACRE_PRC343`), terminal ve kart.
Yanında kimse olmadığı için ağ eşi bir **AI** ile simüle edilir (`TC2_fnc_debugNetPeer`). Eş, gerçek kurallarla denetlenir:
aynı telsiz tipi, aynı kanal, menzil içinde olma. PING'e sunucu PONG döner, mesajlar sunucu RPT'sine yazılır.

## Ağ kuralı (özet)

- Terminal oturumu açık ve **aktif telsizin** var ⇒ ağa katılırsın. Telsiz yoksa / ACRE2 yoksa: **BAĞLANTI YOK**.
- Karşı terminalle **aynı telsiz tipi + aynı kanal** ve **menzil içinde** (CBA ayarı "Telsiz menzil tablosu"; varsayılan PRC-343 = 500 m).
- Durum satırı en geç **5 sn** içinde güncellenir (telsiz değişince anında bildirilir, ayrıca 5 sn'de bir).
- Sınır: menzil sabit tablodur (ACRE'nin arazi modeli değil); kanal bilgisi istemciden gelir, telsizin envanterde olması sunucuda doğrulanır.

## A. Host / editör (Hosted MP: Eden → Play → In Multiplayer)

**A0. Yükleme.** Debug konsolu, Local Exec:
```sqf
[!isNil "TC2_fnc_netServerSend", call TC2_fnc_netGetRadioState]
```
Beklenen: `[true,[true,"ACRE_PRC343_ID_…","ACRE_PRC343",1,"OK"]]`. `NO_ACRE` dönerse ACRE2 yüklü değil / henüz hazır değil.

**A1. Yalnızca sen.** Kartı al (`[player, true] call TC2_fnc_debugCard;`), terminale gir. ANA sekmesinde aşağıda **ağ paneli**:
durum satırı ≤ 5 sn içinde **`BAĞLANTI YOK | menzilde terminal yok | PRC343 K1`** (kırmızı) göstermeli.
PING'e bas ⇒ günlükte `PING gönderiliyor...` ve `BAĞLANTI YOK: menzilde … terminal yok.`

**A2. Simüle eş ekle** (host: Local Exec = sunucu). 300 m uzakta, aynı tip ve kanalda:
```sqf
TC2_p = (createGroup west) createUnit ["B_Soldier_F", player getPos [300, 0], [], 0, "NONE"];
TC2_p disableAI "MOVE";
[TC2_p, "ACRE_PRC343", 1, true] call TC2_fnc_debugNetPeer;
```
Beklenen (≤ 5 sn): **`BAĞLANTI VAR | 1 terminal menzilde | PRC343 K1`** (yeşil).

**A3. Ping / mesaj.** PING ⇒ `PING iletildi: 1 terminal`, ardından `PONG: SIM-… (300 m)`.
Kutuya `deneme` yaz, GÖNDER (veya Enter) ⇒ `SEN: deneme` ve `İLETİLDİ: 1 terminal`.
Sunucu RPT'sinde: `[TC2][NET] MSG | gonderen=… | esler=1 …` ve `[TC2][NET] SIM-ES … aldi: MSG 'deneme'`.
Art arda hızlı basarsan `Bekleyin (2 sn aralık).` görmelisin.

**A4. Menzil.** Eşi 700 m'ye al (PRC-343 menzili 500 m):
```sqf
TC2_p setPos (player getPos [700, 0]);
```
≤ 5 sn ⇒ **BAĞLANTI YOK**; PING ⇒ `BAĞLANTI YOK: menzilde … terminal yok.` Geri al: `TC2_p setPos (player getPos [300, 0]);` ⇒ BAĞLANTI VAR.

**A5. Kanal.** Kendi telsizinin kanalını değiştir:
```sqf
[call acre_api_fnc_getCurrentRadio, 2] call acre_api_fnc_setRadioChannel;
```
≤ 5 sn ⇒ durum satırı `… K2`, **BAĞLANTI YOK** (eş K1'de). Geri: `[call acre_api_fnc_getCurrentRadio, 1] call acre_api_fnc_setRadioChannel;`

**A6. Telsiz yok.** (Sonrasında görevi yeniden başlat.)
```sqf
player removeItem (call acre_api_fnc_getCurrentRadio);
```
≤ 5 sn ⇒ **`BAĞLANTI YOK | aktif telsiz yok`**. (Sunucu telsizin envanterde olduğunu kendisi kontrol eder; istemci eski telsiz ID'sini bildirse bile reddeder.)

**A7. Kapanış.** Pencereyi kapat (ESC). Tekrar aç: günlük temiz, durum yeniden hesaplanır. Kapanınca sunucu kaydından düşersin (başkaları seni artık göremez).

## B. Yerel dedicated + 1 istemci (gerçek ağ yolu)

Kurulum Aşama 1 → bölüm 3 ile aynı. Simüle eş **sunucuda** oluşturulur (Server Exec; sunucuda `player` null, `allPlayers` kullan):
```sqf
TC2_p = (createGroup west) createUnit ["B_Soldier_F", (allPlayers select 0) getPos [300, 0], [], 0, "NONE"];
TC2_p disableAI "MOVE";
[TC2_p, "ACRE_PRC343", 1, true] call TC2_fnc_debugNetPeer;
```
Menzil testi: `TC2_p setPos ((allPlayers select 0) getPos [700, 0]);` (Server Exec).
A1–A7'yi istemcide tekrarla. Ek kontroller:
- Sunucu RPT: `[TC2][NET] MSG | gonderen=<adın> …` (istemciden remoteExec ile geldi).
- **Anti-sahtecilik:** istemcide Local Exec (sunucuya ait bir AI adına gönderim):
  ```sqf
  [(allUnits select {!isPlayer _x}) select 0, objNull, [], "MSG", "sahte", ""] remoteExecCall ["TC2_fnc_netServerSend", 2];
  ```
  Beklenen: sunucu RPT `[TC2][NET] SENDER_MISMATCH …`, istemcide hiçbir şey olmaz.
- **JIP:** çıkıp tekrar gir, terminali yeniden aç ⇒ durum satırı yeniden hesaplanır (kalıcı ağ durumu tutulmaz; kayıtlar terminal açıkken oluşur).

## Beklenen sonuç özeti

| Test | Beklenen |
|------|----------|
| A1 yalnız | BAĞLANTI YOK (menzilde terminal yok) |
| A2 eş 300 m | BAĞLANTI VAR, 1 terminal |
| A3 ping/mesaj | PONG gelir; mesaj sunucu RPT'sinde; 2 sn aralık |
| A4 eş 700 m | BAĞLANTI YOK |
| A5 kanal 2 | BAĞLANTI YOK (K2) |
| A6 telsiz yok | BAĞLANTI YOK (aktif telsiz yok) |
| B sahte gönderim | RPT: SENDER_MISMATCH |

Gerçek ikinci oyuncu ile testi (yazı/okuma, iki istemci) bir arkadaşınla ileride yapabilirsin; mantık aynıdır, yalnızca eş AI yerine gerçek oyuncudur.
