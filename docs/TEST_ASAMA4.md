# Aşama 4 — ortak harekat resmi (COP), düşman işareti ve MicroDAGR testi

Aşama 1–3 çalışıyor olmalı. Gerekenler: kart, ACRE telsizi, terminal, `ACE_microDAGR` eşyası.
Tek kişilik test: ağ eşi Aşama 3'teki gibi AI ile simüle edilir (`TC2_fnc_debugNetPeer`).
Dedicated'de komutları **Server Exec**/**Local Exec** ayrımına dikkat ederek çalıştır (Aşama 3 rehberi).

## Kurallar (özet)

- **HARİTA sekmesi:** terminalin KENDİ haritası. Sen (yeşil, "SEN"), ağındaki dostlar (mavi; **grup liderleri** büyük ve etiketli),
  düşman işaretleri (kırmızı). Normal Arma haritasına (M tuşu) **hiçbir şey eklenmez**.
- **Dostlar:** telsizi olan HERKES (terminali açık olmasa da), aynı telsiz tipi + kanal + senin telsiz menzilin içinde. Telsizi olan herkes durumunu 10 sn'de bir sunucuya bildirir.
- **İşaretler** AĞA aittir (telsiz tipi + kanal). Görebilmek için aynı ağda olmalı ve işareti koyanın menzili içinde olmalısın. Süre: 30 dk (CBA ayarı). Ağ başına en çok 30 işaret.
- **MicroDAGR:** yalnızca **grup lideri** ve envanterinde **ACE MicroDAGR** olan birim, görebildiği düşman işaretlerini DAGR'ına `TC2 INF <grid>` adlı **waypoint** olarak alır.
  Kendi waypoint'lerine dokunulmaz. Dostlar DAGR'a yazılmaz (waypoint değil, hareketli); yalnızca terminal haritasında.

## A. Tek kişilik test (host/editör ya da dedicated)

**A1. Harita.** Kartı al, terminale gir, **HARİTA** sekmesine geç. Beklenen: harita senin konumunda, yeşil `SEN`; durum satırı `0 dost | 0 düşman işareti`
(telsizin varsa). Telsiz yoksa: `BAĞLANTI YOK | …`.

**A2. Dost (simüle).** Server/Local Exec (host'ta aynı):
```sqf
TC2_p = (createGroup west) createUnit ["B_Soldier_F", player getPos [300, 0], [], 0, "NONE"];
TC2_p disableAI "MOVE";
[TC2_p, "ACRE_PRC343", 1, true] call TC2_fnc_debugNetPeer;
```
≤ 5 sn ⇒ 300 m'de **mavi** simge, durum `1 dost`. Eşi 700 m'ye al ⇒ kaybolur (PRC-343 menzili 500 m).

**A3. İşaret koy.** `DÜŞMAN PİYADE` düğmesine bas (kırmızı yanar, durum: *Haritaya tıklayın*), haritada bir yere tıkla.
Beklenen: **kırmızı** simge + `DÜŞMAN PİYADE 0 dk`, durum `İŞARET KONDU | grid …`. Sunucu RPT: `[TC2][COP] KOYULDU id=1 …`.
Hızlı art arda tıklarsan `Bekleyin (1.5 sn aralık)`.

**A4. MicroDAGR.** Eşyayı al ve **grup lideri** olduğundan emin ol (tek başına isen sensin):
```sqf
player addItem "ACE_microDAGR";
```
İşaret koyunca (ya da en geç 10 sn içinde) ekranda `MicroDAGR: yeni düşman işareti.` Sonra:
- Kontrol (Local Exec): `ACE_player getVariable ["ace_microdagr_waypoints", []]` ⇒ `[["TC2 INF 123456",[x,y,z]]]`
- DAGR'ı aç (ACE self-menü → Ekipman → MicroDAGR ya da ACE tuşu): waypoint listesinde `TC2 INF …`; DAGR haritasında simge görünmesi için
  ACE ayarı *MicroDAGR → Haritada tüm waypoint'leri göster* açık olmalı.
- **Normal harita (M)**: işaret OLMAMALI.

**A5. Silme.** `İŞARET SİL` düğmesine bas, kırmızı işaretin yanına tıkla ⇒ `İŞARET SİLİNDİ`; simge kaybolur, DAGR'daki `TC2 …` waypoint'i silinir.

**A6. Süre dolumu.** CBA ayarı `Ortak Harekat Resmi (COP) → İşaret ömrü`ni 1 dk yap, işaret koy, bekle ⇒ ≤ 1 dk + 10 sn içinde harita ve DAGR'dan düşer.

**A7. Lider kuralı.** Liderliği başkasına ver:
```sqf
TC2_ai = (group player) createUnit ["B_Soldier_F", player getPos [3, 0], [], 0, "NONE"];
(group player) selectLeader TC2_ai;
```
≤ 10 sn ⇒ `TC2` waypoint'leri DAGR'dan silinir. Geri: `(group player) selectLeader player;` ⇒ tekrar gelir.

**A8. Ağ kuralı.** Telsiz kanalını değiştir (Local Exec: `[call acre_api_fnc_getCurrentRadio, 2] call acre_api_fnc_setRadioChannel;`) ⇒ işaretler haritadan ve DAGR'dan kaybolur (başka ağdasın);
kanalı 1'e alınca geri gelir.

## B. Dedicated + istemci

A1–A8'i istemcide tekrarla; simüle eşi Server Exec ile kur (`allPlayers select 0` kullan, Aşama 3). Sunucu RPT'sinde `[TC2][COP] KOYULDU/SILINDI` satırları görünmeli.
Anti-sahtecilik: istemciden Local Exec ile başkası adına gönderim denemesi `SENDER_MISMATCH` almalı:
```sqf
[(allUnits select {!isPlayer _x}) select 0, objNull, [], "INF", [0,0,0]] remoteExecCall ["TC2_fnc_copPlace", 2];
```

## Beklenen sonuç özeti

| Test | Beklenen |
|------|----------|
| A1 | harita açılır, `SEN` yeşil |
| A2 | 300 m dost mavi görünür, 700 m'de kaybolur |
| A3 | kırmızı işaret + grid, RPT `KOYULDU` |
| A4 | DAGR'da `TC2 INF …` waypoint; M haritasında işaret yok |
| A5 | işaret ve DAGR waypoint'i silinir |
| A6 | süre dolunca kaybolur |
| A7 | lider değilsen DAGR'da TC2 waypoint yok |
| A8 | kanal değişince işaretler kaybolur |
