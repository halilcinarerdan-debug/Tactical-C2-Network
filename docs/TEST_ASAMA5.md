# Aşama 5 — dijital 9-Line CAS testi (tek kişilik)

Aşama 1–4 çalışıyor olmalı. Gerekenler: kart, ACRE telsizi, terminal. 9-Line'ın doktrin kuralları `docs/DOKTRIN_NOTLARI.md`'de.
Tek başına test için iki yardımcı var: **simüle pilot** (`TC2_fnc_debugCasPilot`, AI) ve **kendine gönderme** (CBA ayarı, yalnızca test).

## Kurallar (özet)

- **Gönderen:** yalnızca JTAC. Sistem JTAC'ı şu yollarla tanır (öncelik sırasıyla): (1) **Zeus modülü** "JTAC Ata / Kaldır" ya da Eden'de birimin init alanı `this setVariable ["TC2_jtac", true, true];`
  (`false` yazılırsa sınıf/rol JTAC olsa bile kaldırır); (2) Eden **rol açıklamasında** `JTAC` veya `FAC` geçmesi; (3) CBA ayarındaki **JTAC sınıf listesi** (varsayılan vanilla Recon JTAC).
- **Alıcı:** JTAC'la **aynı telsiz tipi + kanal + menzilde** ve **hava aracında** olan mürettebat (Plane = sabit kanat, diğerleri = döner kanat).
- **Form (tek ekran):** KONTROL TÜRÜ (Type 1/2/3), BOT/BOC (Type 1 ⇒ yalnız BOT), 1 IP/BP, 2 HEADING (+offset), 3 DISTANCE (sabit kanat nm / döner kanat m),
  4 ELEVATION (ft MSL), 5 HEDEF TANIMI, 6 KONUM (HARİTA sekmesindeki işaretten; yükseklik otomatik dolar), 7 İŞARET (+lazer kodu), 8 DOST (m + yön), 9 EGRESS,
  REMARKS, KISITLAR (son saldırı yönü, ACA, danger close + komutan baş harfleri, TOT/TTT).
- **Doğrulama:** sunucuda (doktrin). Hatalı formda kırmızı durum satırı ilk hatayı söyler.
- **Pilot:** gelen 9-Line bildirimi + bip; pencere **kendiliğinden açılmaz**. ACE self menü ⇒ **CAS 9-Line**.
- **Zorunlu geri okuma:** satır 4, satır 6 ve verilmiş tüm kısıtlar. Sunucu karşılaştırır; JTAC ve pilot renkli sonucu (TAMAM / HATA + doğru değer) görür. Yanlışsa tekrar okunur.
- **İPTAL:** JTAC her zaman iptal edebilir (doktrin). Pilot bilgilendirilir.

## Z. JTAC atama (Zeus modülü ve roller)

**Z1. Zeus.** Eden'de **Systems → Multiplayer → Game Master** modülü ekle (Owner: `#adminLogged`), hosted/dedicated'de `#login` ile admin ol, **Y** ile Zeus'u aç.
Modüller sekmesinde **Tactical C2 Network → JTAC Ata / Kaldır**'ı bir askerin **üzerine** koy. Beklenen: `<ad>: JTAC olarak ATANDI.`; modül kendini siler.
Aynı askere tekrar koy ⇒ `JTAC yetkisi KALDIRILDI.` Sunucu RPT: `[TC2][JTAC] ATANDI/KALDIRILDI | birim=…`. Modülü boş yere (birimin üzerinde değil) koyarsan `Modülü bir birimin ÜZERİNE koyun.`
Not: Zeus yalnızca düzenleyebildiği (editable) birimlere ekleyebilir.

**Z2. Yetki kontrolü.** O askerle terminale gir ⇒ CAS sekmesi artık `JTAC YETKİSİ GEREKLİ` demez; Zeus olmayan biri bu atamayı yapamaz (sunucu RPT: `[TC2][JTAC] RED`).

**Z3. Rol açıklaması.** Eden'de birimin **Attributes → Role Description** alanına `JTAC` yaz (ya da `Takim JTAC`, `FAC`) ⇒ oyun başında modül gerekmeden JTAC sayılır.

**Z4. Sınıf.** Vanilla `B_recon_JTAC_F` (Recon JTAC) askeri ⇒ varsayılan olarak JTAC. Mod sınıfları CBA ayarından (`JTAC sınıfları`) eklenir.

**Z5. Açık kaldırma.** Sınıfça JTAC olan askere Zeus modülünü koy ⇒ `KALDIRILDI` (açık `false`, sınıfı geçersiz kılar).

## A. JTAC yetkisi ve form

**A1. Yetkisiz.** Terminalde **CAS** sekmesi ⇒ kırmızı/sarı durum: `JTAC YETKİSİ GEREKLİ`.

**A2. Yetki ver:** Zeus modülüyle (Z1) ya da hızlıca Local Exec: `player setVariable ["TC2_jtac", true, true];` ⇒ sekmeyi yeniden aç. Alıcı listesi `— ağda hava aracı yok —` görünür (henüz pilot yok).

**A3. Hedef işareti.** HARİTA sekmesinde `DÜŞMAN PİYADE` ile bir işaret koy (Aşama 4).

**A4. Simüle pilot** (Server Exec; host'ta Local Exec). Dedicated'de `player` yerine `(allPlayers select 0)`:
```sqf
TC2_pilot = (createGroup west) createUnit ["B_Soldier_F", player getPos [200, 0], [], 0, "NONE"];
TC2_pilot disableAI "MOVE";
[TC2_pilot, "ACRE_PRC343", 1, "RW", false] call TC2_fnc_debugCasPilot;
```
≤ 5 sn ⇒ CAS sekmesinde ALICI listesinde `SIM-PILOT … [RW] 200 m`.

**A5. Formu doldur ve gönder.** Örnek: TYPE 2, BOT; 1 `IP RED`; 2 `90`; 3 `1500` (döner kanat: 100 m katı); 4 otomatik; 5 otomatik; 6 işareti seç; 7 LAZER + `1688`; 8 `400` + `S`; 9 `WEST`; **GÖNDER**.
Beklenen: `9-LINE İLETİLDİ | alıcı: SIM-PILOT … | geri okuma bekleniyor`, ~3 sn sonra `GERİ OKUMA DOĞRU` ve sağ alttaki alanda yeşil **TAMAM** satırları (SATIR 4, SATIR 6 ve verdiğin kısıtlar).
Sunucu RPT: `[TC2][CAS] GONDERILDI id=1 …` ve `[TC2][CAS] GERI OKUMA id=1 | READBACK_OK`.

**A6. Yanlış geri okuma.** Simüle pilotu "yanlış okur" yap (Server Exec): `[TC2_pilot, "ACRE_PRC343", 1, "RW", true] call TC2_fnc_debugCasPilot;` ve tekrar gönder
(3 sn aralık). Beklenen: `GERİ OKUMA YANLIŞ`, kırmızı **HATA SATIR 6 KONUM - doğru: …**.

**A7. Doğrulama kuralları.** Her biri anında kırmızı satırla reddedilmeli:
- TYPE 1 seçince BOC kutusu **kilitlenir** (BOT'ta kalır).
- Lazer seçilmeden kod kutusu kapalı; LAZER + `12` ⇒ `lazer işaretinde 4 haneli kod gerekli`.
- Döner kanatta mesafe `1550` ⇒ `100 m'nin katı olmalı`. Heading `400` ⇒ `0-359`.
- Danger close kutusuna `1` ⇒ `komutanın baş harfleri (2-3 harf)`.
- Dost mesafesi `400` ama yön `—` ⇒ `mesafe ve yön birlikte`.

**A8. İptal.** Yeni bir 9-Line gönder, ardından **İPTAL** ⇒ `TALEP İPTAL EDİLDİ`.

**A9. Menzil.** Simüle pilotu 700 m'ye al (PRC-343 menzili 500 m): `TC2_pilot setPos (player getPos [700, 0]);` ⇒ ≤ 5 sn'de alıcı listeden **kaybolur**; zorla gönderirsen `NO_TARGET`.

## B. Pilot penceresi (tek başına)

CBA ayarı: `Options → Addon Options → Tactical C2 Network → Joint Fires (9-Line CAS)` ⇒ **TEST: 9-Line'ı kendine gönderebil** AÇ.

1. CAS sekmesinde ALICI = **`SEN (TEST)`**, formu doldur, GÖNDER.
2. Ekranda `CAS 9-LINE ALINDI` bildirimi + kısa bip. Terminali kapat.
3. ACE self menü (Sol Windows + Ctrl) ⇒ **CAS 9-Line** ⇒ pencere açılır: solda önsöz + 9 satır, sağda geri okuma kutuları (yalnızca verdiğin kısıtlar görünür).
4. Yükseklik kutusuna yanlış bir sayı yaz, **GERİ OKU** ⇒ kırmızı **HATA SATIR 4 YÜKSEKLİK - doğru: … ft**. Düzelt ve konumu 10 haneli yaz (`12345 67890` biçimi; boşluklar önemsiz) ⇒ **TAMAM**.
5. Kapat ⇒ ACE self menüde **CAS 9-Line** kaybolur (talep tamamlandı).
6. Uçak içinde: bir helikopterde/uçakta aynı menüden aç. Not: pencere açıkken uçuş tuşları pencereye gider; sakin uçuşta ya da ikinci pilotla kullan.

## C. Dedicated + istemci

A ve B'yi tekrarla (simüle pilot Server Exec ile). Sunucu RPT'sinde `[TC2][CAS]` satırları görünmeli. Anti-sahtecilik: istemciden başkası adına gönderim denemesi `SENDER_MISMATCH` almalı:
```sqf
[(allUnits select {!isPlayer _x}) select 0, objNull, [], [], ""] remoteExecCall ["TC2_fnc_casSend", 2];
```

## F. Saha cihazı (laptop olmadan)

1. Terminale **gitmeden**, ACE self menü ⇒ **TC2 Saha Cihazı** ⇒ ilerleme çubuğu (*Saha cihazı bağlanıyor...*) ⇒ pencere açılır. Başlık: `TC2 SAHA CİHAZI | SAHA <çağrı adı> | <adın>`.
2. Kartın olmasa bile açılmalı (varsayılan). CBA ayarı `Saha cihazı da kimlik kartı istesin` AÇIK ve kart YOK ⇒ `ERİŞİM REDDEDİLDİ: Kimlik kartı`.
3. CAS sekmesinden Bölüm A'daki gibi 9-Line gönder ⇒ aynı şekilde çalışır.
4. Üs görünürlüğü: ikinci bir oturum (terminal) açıkken ANA günlüğünde mavi `CAS #1  JTAC … alıcı … TYPE 2 BOT` ve `CAS #1  geri okuma DOĞRU` satırları görünür.
5. Pencere açıkken ölürsen/bayılırsan pencere kapanır (terminalle aynı).

## Beklenen sonuç özeti

| Test | Beklenen |
|------|----------|
| A1 | `JTAC YETKİSİ GEREKLİ` |
| A5 | iletildi → geri okuma doğru, yeşil TAMAM satırları |
| A6 | yanlış okuma → kırmızı HATA + doğru değer |
| A7 | doktrin ihlalleri reddedilir (Type 1 ⇒ BOC kilitli, lazer kodu, 100 m katı, ...) |
| A8 | iptal çalışır |
| A9 | menzil dışı pilot listede yok |
| B | bildirim+bip, ACE self menüden açılır, geri okuma sonucu renkli, tamamlanınca eylem kaybolur |
