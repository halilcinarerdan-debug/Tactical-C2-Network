# Tactical C2 Network (TC2) — ACE3 + ACRE2 komuta-kontrol ağı

Oyuncuların "M tuşuyla her şeyi gördüğü" bir sistem değil; **OPSEC** kurallarının işlediği, yetki seviyeli, fiziksel bir
karargah terminali (laptop) üzerinden **9-Line CAS**, **istihbarat** ve **lojistik** akışı. Doktrin: JP 3-09.3 ve JP 3-09
(özet: [`docs/DOKTRIN_NOTLARI.md`](docs/DOKTRIN_NOTLARI.md)).

Tek mod (`@TC2`), tek PBO (`tc2_main.pbo`). Gerektirir: **CBA_A3**, **ACE3**. **ACRE2** Aşama 3'ten itibaren eklenecek.

## Yol haritası

| # | Aşama | Durum |
|---|-------|-------|
| 1 | Fiziksel terminal + OPSEC (kimlik kartıyla erişim) | ✅ hazır (test bekliyor) |
| 2 | Terminal arayüzü (yeşil/siyah, sekmeli; UAV sekmesi yer tutucu) | ✅ hazır (test bekliyor) |
| 3 | ACRE2 veri ağı + basit mesajlaşma (telsiz/kanal/menzil kontrolü, PING/PONG) | ✅ hazır (test bekliyor) |
| 4 | Ortak harekat resmi (COP): terminal haritası, düşman işareti, ACE MicroDAGR | ✅ hazır (test bekliyor) |
| 5 | Dijital 9-Line CAS talebi (Type 1/2/3, BOT/BOC) | ⏳ |
| 6 | Sınıflandırılmış belgeler (OPORD/INTSUM) + lojistik, Level 1/2/3 | ⏳ |

## Depo yapısı

Depo kökü, P: sürücüsünde `P:\z\tc2` olacak şekilde konumlandırılır (aşağıya bak).

```
mod.cpp                                  @TC2 kök klasörüne kopyalanır
addons/main/                             -> tc2_main.pbo   (prefix: z\tc2\addons\main)
    $PBOPREFIX$                          Mikero bu dosyadan prefix'i okur
    config.cpp                           CfgPatches, TC2_Terminal_F, CfgFunctions, CfgRemoteExec, CBA XEH
    XEH_preInit.sqf                      tüm makineler: CBA ayarları
    XEH_postInit.sqf                     yalnızca istemci: ACE eylemleri
    core/                                ortak yardımcılar
        fn_notify.sqf                    ACE tarzı bildirim (hata/başarı/bilgi)
        fn_debugInfo.sqf                 teşhis: rol, kart sınıfı, envanter, yakın terminaller (panoya kopyalar)
        fn_debugCard.sqf                 TEST: kartı ver / al
    terminal/                            1. aşama
        fn_terminalInitSettings.sqf      CBA ayarları
        fn_terminalPostInit.sqf          istemci kurulumu
        fn_terminalInitActions.sqf       ACE eylemi (TC2_Terminal_F sınıfına)
        fn_terminalCreate.sqf            [SUNUCU] çalışma zamanında terminal yarat
        fn_terminalGetId.sqf             terminal kimliği
        fn_terminalOpen.sqf              [İSTEMCİ] onay sonrası terminal arayüzünü açar (uiOpen)
        fn_accessGetCardClasses.sqf      kart ayarını çöz (Item_ ön eki toleransı)
        fn_accessHasCard.sqf             birimde kart var mı (saf fonksiyon)
        fn_accessCheck.sqf               [SUNUCU] erişim kararı (saf fonksiyon)
        fn_accessReasonText.sqf          neden kodu -> Türkçe mesaj
        fn_accessRequest.sqf             [İSTEMCİ] talebi başlat (ön kontrol + ilerleme çubuğu)
        fn_accessServerHandle.sqf        [SUNUCU] göndereni doğrula, karar ver, kayıt tut, yanıtla
        fn_accessResult.sqf              [İSTEMCİ] sunucu kararını uygula
    ui/                                  2. aşama (terminal penceresi)
        fn_uiOpen.sqf                    pencereyi kurar (ctrlCreate), olayları bağlar
        fn_uiSelectTab.sqf               sekme vurgusu + içerik
        fn_uiTabText.sqf                 sekme metinleri (sonraki aşamalar buraya dolar)
        fn_uiWatch.sqf                   saniyede 1: oturum geçerli mi (yalnızca pencere açıkken)
        fn_uiOnUnload.sqf                temizlik + TC2_terminalClosed olayı
    net/                                 3. aşama (ACRE2 veri ağı)
        fn_netGetRadioState.sqf          [İSTEMCİ] aktif ACRE telsizi oku (acre_api: getCurrentRadio/getBaseRadio/getRadioChannel)
        fn_netReportState.sqf            [İSTEMCİ] durumu sunucuya bildir
        fn_netSend.sqf / fn_netUiSend    [İSTEMCİ] MSG / PING / PONG gönder
        fn_netOnStatus / netOnAck        [İSTEMCİ] sunucu yanıtları (BAĞLANTI VAR/YOK)
        fn_netReceive.sqf                [İSTEMCİ] gelen mesaj / PING (otomatik PONG) / PONG
        fn_netServerSession.sqf          [SUNUCU] oturum kaydı + doğrulama (erişim, telsiz envanterde mi)
        fn_netServerPeers.sqf            [SUNUCU] aynı tip+kanal+menzil içi eşler
        fn_netServerReport / ServerSend  [SUNUCU] rapor ve gönderim işleyicileri
        fn_netRangeOf / netSanitize ...  menzil tablosu, metin temizleme, yardımcılar
        fn_debugNetPeer.sqf              TEST: AI'ı simüle ağ eşi yap
    cop/                                 4. aşama (ortak harekat resmi)
        fn_copHeartbeat.sqf              [İSTEMCİ] telsizi olan herkes 10 sn'de bir durumunu bildirir
        fn_copFieldReport.sqf            [SUNUCU] saha varlığı kaydı + doğrulama
        fn_copFriendsOf / copMarkersFor  [SUNUCU] ağdaki dostlar / görülebilen işaretler (TTL, menzil)
        fn_copRequest / Place / Remove   [SUNUCU] harita verisi, işaret koy, işaret sil
        fn_copSyncUnit / copPush         [SUNUCU] liderlerin MicroDAGR özetini eşzamanla
        fn_copDagrSync.sqf               [İSTEMCİ] işaretleri DAGR waypoint'i olarak yaz
        fn_copUi*.sqf                    [İSTEMCİ] HARİTA sekmesi: kurulum, çizim, tıklama, durum
docs/
    DOKTRIN_NOTLARI.md                   doktrinden çıkan kurallar (9-Line, Type 1/2/3, BOT/BOC, roller)
    TEST_ASAMA1.md                       tek başına test: editör, hosted MP, yerel dedicated
    TEST_ASAMA2.md                       arayüz testi
    TEST_ASAMA3.md                       ağ/mesajlaşma testi (tek kişilik, simüle eş)
    TEST_ASAMA4.md                       COP / işaret / MicroDAGR testi
    UAV_ENTEGRASYON.md                   UAV terminali entegrasyonu: seçenekler ve öneri (karar bekliyor)
```

## Mikero ile derleme

1. Mikero araçlarını (**pboProject**, MakePbo, DePbo) ve P: sürücüsünü kur.
2. Depoyu `P:\z\tc2` yoluna getir. Ya doğrudan oraya klonla ya da yönetici komut isteminde:
   ```bat
   mklink /J "P:\z\tc2" "C:\yol\Tactical-C2-Network"
   ```
   (`P:\z` klasörü önceden var olmalı.) Sonuçta `P:\z\tc2\addons\main\config.cpp` bulunmalı.
3. pboProject'te kaynak klasör: `P:\z\tc2\addons\main`, çıktı klasörü: `...\@TC2\addons`.
   Prefix, klasördeki `$PBOPREFIX$` dosyasından okunur (`z\tc2\addons\main`).
4. `mod.cpp` dosyasını `...\@TC2\` köküne kopyala.
5. **Vanilla taban sınıf:** `TC2_Terminal_F`, vanilla `Land_Laptop_unfolded_F` sınıfından türer (`A3_Structures_F_Items_Electronics` yaması).
   pboProject bu taban sınıfı çözebilmek için vanilla Arma 3 verisine ihtiyaç duyar: Arma 3 Tools → **Mount & Populate P: drive**
   (`P:\a3\structures_f\items\electronics\config.cpp` var olmalı). Yoksa "undefined base class" hatası alırsın.
6. `requiredAddons` (cba_main, ace_main, ace_common, ace_interact_menu) bulunamadı uyarısı için `a3ace3ex` deposundaki README'deki notla aynı çözüm geçerlidir.
7. İmza: dedicated sunucuda `verifySignatures` açıksa PBO'yu `.biprivatekey` ile imzala, `.bikey`'i sunucunun `keys/` klasörüne koy.
   **`.biprivatekey` dosyasını asla depoya koyma** (`.gitignore` engeller).

Sonuç: `@TC2\addons\tc2_main.pbo` (+ varsa `.bisign`) ve `@TC2\mod.cpp`.

## Kurulum / başlatma

```
-mod=@CBA_A3;@ace;@TC2
```

**Sunucu ve tüm oyuncular aynı sürümü yüklemelidir.** Erişim kararı sunucuda verildiği için sunucuda `@TC2` yoksa terminal
"SUNUCU YANIT VERMEDİ" zaman aşımı mesajı verir. `@TC2`, CBA ve ACE'den sonra gelmelidir. `@TAC` (a3ace3ex) ile birlikte kullanılabilir.

## Aşama 4 – Ortak harekat resmi (COP), düşman işareti, MicroDAGR

**HARİTA** sekmesi terminalin kendi haritasıdır: sen (yeşil), ağındaki dostlar (mavi; grup liderleri büyük ve etiketli),
düşman işaretleri (kırmızı). **Normal Arma haritasına (M) hiçbir şey eklenmez.** `DÜŞMAN PİYADE` düğmesi + haritaya tıklama ile işaret konur,
`İŞARET SİL` + tıklama ile silinir.

| Konu | Kural |
|------|-------|
| Dostlar | telsizi olan HERKES (terminali açık olmasa da), aynı telsiz tipi + kanal + senin menzilin içinde. Konumlar sunucuda okunur (istemciye güvenilmez). Telsizi olan her istemci durumunu 10 sn'de bir bildirir (tek hafif CBA PFH). |
| İşaretler | AĞA aittir (tip + kanal); görmek için aynı ağda ve işareti koyanın menzilinde olmalısın. Ömür 30 dk (CBA), ağ başına en çok 30. Sunucuda saklanır ⇒ terminali sonradan açan/JIP olan görür. |
| MicroDAGR | yalnızca **grup lideri** + envanterinde **ACE MicroDAGR** olan birim, görebildiği işaretleri `TC2 INF <grid>` **waypoint**'i olarak alır. Liderlik/DAGR/kanal/respawn değişimi 10 sn içinde, işaret koyma/silme anında eşzamanlanır. Kendi waypoint'lerine dokunulmaz. |
| Güvenlik | tüm işlemler sunucuda: gönderen (`remoteExecutedOwner`), oturum (kart, 5 m, telsiz envanterde), 1.5 sn aralık, konum biçimi doğrulaması; `[TC2][COP]` RPT kaydı. |
| Performans | HARİTA sekmesi dışında ek maliyet yok; harita verisi sekme açıkken 5 sn'de bir; çizim yalnızca `drawIcon` (önbellekten). |

**Bilinen sınırlar:**
- MicroDAGR'ın "işaret çizme" API'si yok; kullanılabilir olan **waypoint** listesidir. Waypoint'ler `ace_microdagr_waypoints` oyuncu değişkenine yazılır (ACE'in genel API'si değil, yalnızca `deviceAddWaypoint` genel); ACE sürümü değişirse bu biçim kontrol edilmeli.
- Dostlar DAGR'a yazılmaz (hareketli, waypoint değil). DAGR'da simge görünmesi için ACE ayarı *Haritada tüm waypoint'leri göster* açık olmalı.
- Yalnızca `DÜŞMAN PİYADE` türü var; yeni tür eklemek `copTypeName` + `copPlace` türler listesi + düğme.
- Telsiz tipi/kanal bilgisi istemciden gelir (Aşama 3 ile aynı sınır).

Test: [`docs/TEST_ASAMA4.md`](docs/TEST_ASAMA4.md).

## Aşama 3 – ACRE2 veri ağı ve basit mesajlaşma

Terminal ANA sekmesinde **ağ paneli**: durum satırı, mesaj kutusu, GÖNDER, PING ve günlük.

**Kural:** iki terminal arası veri yalnızca **ikisinin de aktif ACRE2 telsizi varsa**, **aynı telsiz tipi ve aynı kanaldaysa** ve
**menzil içindeyse** gider. Aksi halde **BAĞLANTI YOK** (aktif telsiz yok / ACRE2 yok / menzilde terminal yok).
Ek ağ adı yoktur; "aynı kanal = aynı ağ".

| Parça | Nerede | Nasıl |
|-------|--------|-------|
| Telsiz okuma | **istemci** | ACRE2 genel API'si yalnızca yerel oyuncuyu sorgular: `getCurrentRadio`, `getBaseRadio`, `getRadioChannel` |
| Rapor | istemci → **sunucu** | terminal açılınca, durum değişince, açıkken 5 sn'de bir (mevcut 1 sn'lik uiWatch döngüsünde; yeni döngü yok) |
| Doğrulama / karar | **sunucu** | gönderen (`remoteExecutedOwner`), erişim (`accessCheck`), telsiz **envanterde mi** (sunucu kendisi bakar), tip+kanal+mesafe |
| Mesaj/PING/PONG | istemci → sunucu → eş istemciler | yalnızca menzildeki eşlere `remoteExecCall`; PING'e eşin istemcisi otomatik PONG döner |
| Güvenlik | sunucu | mesaj temizlenir (`<`,`>`,`&` atılır), 120 karakter, 2 sn gönderim aralığı, tüm gönderimler RPT'ye `[TC2][NET]` |
| JIP | — | ağ kaydı yalnızca terminal açıkken vardır; kalıcı durum yok |

**Menzil tablosu** (CBA: `Tactical C2 Network > Ağ (ACRE2)`), metre: PRC-343 500, PRC-148 5000, PRC-152 8000, PRC-117F 20000, PRC-77 15000,
BF-888S 1500, SEM-52SL 3000, SEM-70 10000, diğer 3000. Değerler yaklaşık oyun-dengesi tahminidir; ayardan değiştirilir.

**Bilinen sınırlar (dürüstçe):**
- **ACRE2'nin arazi/yayılım modeli kullanılmıyor.** ACRE'nin sinyal hesabı genel API değil (`Public: No`) ve dış eklenti üzerinden asenkron çalışıyor; bunun yerine telsiz tipine bağlı sabit menzil tablosu kullanıldı. İleride ACRE sinyaliyle değiştirilebilir (bir prototip gerekir).
- **Kanal bilgisi istemciden gelir** (sunucu başkasının ACRE durumunu okuyamaz); telsizin envanterde olması sunucuda doğrulanır.
- Araç/rack telsizleri (envanterde olmayan) bu aşamada sayılmaz.
- Telsiz tipi aynı olmalı: farklı tipler (ör. PRC-343 ile PRC-152) aynı kanal numarasında olsa da birbirini görmez.
- ACRE2'de genel bir "telsiz kapalı" durumu yok; **aktif telsiz yok = bağlantı yok** olarak ele alındı.

Test: [`docs/TEST_ASAMA3.md`](docs/TEST_ASAMA3.md) (tek kişilik; AI ile simüle edilen ağ eşi).

## Aşama 2 – Terminal arayüzü

Ekranın ortasında %70 boyutunda yeşil/siyah pencere; sekmeler: **ANA, HARİTA, CAS, İSTİHBARAT, LOJİSTİK, UAV**.
Yalnızca ANA gerçek veri gösterir; diğerleri sonraki aşamalarda dolar (`fn_uiTabText.sqf`).
Kapanma: **KAPAT**, **ESC**, ya da otomatik (kart çekildi, 5 m'den uzaklaşıldı, ölüm/bilinç kaybı).

- **Performans:** kare başına UI kodu yok. Sekme değişimi düğme olayıyla; oturum kontrolü saniyede 1 kez (CBA PFH, yalnızca pencere açıkken, kapanınca kendini kaldırır).
- **Kurulum:** config'te yalnızca boş diyalog (`TC2_TerminalDialog`, idd 92000); kontroller `ctrlCreate` ile scriptte kurulur.
- **Olaylar (yerel CBA):** `TC2_terminalOpened [terminal, birim]`, `TC2_terminalClosed [terminal]`; sonraki aşamalar buna bağlanır.
- **UAV:** bkz. [`docs/UAV_ENTEGRASYON.md`](docs/UAV_ENTEGRASYON.md). Test: [`docs/TEST_ASAMA2.md`](docs/TEST_ASAMA2.md).

## Aşama 1 – Fiziksel terminal + OPSEC

### Nasıl çalışır

1. **Terminal objesi:** `TC2_Terminal_F` ("TC2 Command Terminal"), vanilla açık laptop modelinin kendi sınıfımız.
   Eden'de **Objects (F6) → Tactical C2 Network → Terminals**; Zeus'ta aynı kategori; script ile `TC2_fnc_terminalCreate`.
2. **Etkileşim:** ACE ana etkileşim menüsünde (Sol Windows) terminale bakınca **Terminale Giriş (Kimlik Kartı)** eylemi görünür.
3. **Kimlik kartı:** envanterde (üniforma/yelek/çanta) ya da atanmış eşyalarda kart yoksa anında
   *"ERİŞİM REDDEDİLDİ: Kimlik kartı (CAC) bulunamadı."* hatası verilir. Kart varsa 2 sn'lik *"Kimlik doğrulanıyor..."* çubuğu çalışır.
4. **Sunucu kararı:** çubuk bitince talep sunucuya gider; sunucu kartı, mesafeyi (≤ 5 m), canlılığı ve bilinci **kendi verisiyle** yeniden denetler.
   Onayda *"ERİŞİM ONAYLANDI"* gösterilir. Ardından terminal arayüzü açılır (Aşama 2).

### Kimlik kartı sınıfı hakkında önemli not (`Item_CAC_Card`)

Arma'da `Item_Xyz`, yere bırakılan eşyanın **CfgVehicles** sınıfıdır (WeaponHolder); envanterdeki gerçek eşya çoğu zaman **CfgWeapons**'taki ön eksiz `Xyz`'dir.
Bu yüzden ayarda `Item_CAC_Card` yazılı olsa bile **hem `Item_CAC_Card` hem `CAC_Card`** kabul edilir. Hangisinin gerçek olduğunu görmek için oyunda:

```sqf
[] call TC2_fnc_debugInfo;   // "aday" satırlarında CfgWeapons=true/false yazar; çıktı panoya da kopyalanır
```

İkisi de `CfgWeapons=false` ise kartı sağlayan mod yüklü değildir ya da sınıf adı farklıdır. Geçici olarak ayarı `ItemGPS` gibi mevcut bir eşyaya çevirip test edebilirsin.
Projenin kendi kartı **`TC2_CAC_Card`** her zaman kabul edilir; ayar yalnızca **ek** (harici mod) kart sınıfları içindir.

### CBA ayarları (`Options > Addon Options > Tactical C2 Network > Terminal ve Erişim (OPSEC)`)

| Ayar | Varsayılan | Kapsam | Açıklama |
|------|-----------|--------|----------|
| `TC2_terminal_enabled` | açık | global | Kapalıysa eylem görünmez, sunucu her talebi reddeder |
| `TC2_access_cardClasses` | `Item_CAC_Card` | global | **Ek** kart sınıf(lar)ı (`TC2_CAC_Card` her zaman geçerli); `;` veya `,` ile ayır |
| `TC2_access_authTime` | 2 sn | global | Kart okutma çubuğu süresi; 0 = anında |
| `TC2_debug` | kapalı | istemci | Bildirimleri sohbet satırına da yazar |

### MP mantığı (server / client)

| Adım | Nerede | Nasıl |
|------|--------|-------|
| CBA ayarları | **tüm makineler** | `XEH_preInit`; global ayarlar sunucudan istemciye senkron |
| ACE eylemi | **istemci** | `XEH_postInit` + `hasInterface`; eylem **sınıfa** bağlı → JIP/respawn için ek iş yok |
| Ön kontrol (kart var mı) | istemci | yalnızca kolaylık (kartsız oyuncu 2 sn beklemesin); **yetki değildir** |
| Erişim kararı | **sunucu** | `TC2_fnc_accessServerHandle` → `TC2_fnc_accessCheck`; istemciden `remoteExecCall` ile **yalnızca sunucuya** |
| Gönderen doğrulama | sunucu | `remoteExecutedOwner` ≠ birimin sahibi → `SENDER_MISMATCH` (başkası adına talep edilemez), yanıt verilmez |
| Denetim kaydı | sunucu RPT | `[TC2][ACCESS] ONAY/RED \| neden=… \| terminal=… \| birim=… \| uid=… \| gonderen=… \| mesafe=…` |
| Yanıt | sunucu → talep eden istemci | `remoteExecCall` yalnızca o makineye; host/SP'de doğrudan çağrı |
| Zaman aşımı | istemci | 8 sn yanıt yoksa talep bırakılır, menü tekrar açılır (sunucuda mod yoksa görünür) |
| JIP | — | durum tutulmaz; terminal global obje, eylem sınıfa bağlı. `TC2_terminalId` global `setVariable` ile JIP'e iletilir |

**Performans:** `onEachFrame` / `waitUntil` döngüsü yok. ACE koşul kodu yalnızca menü terminale bakarken çalışır ve ucuzdur.
İlerleme çubuğu ACE'in kendi CBA PerFrameHandler'ıdır; zaman aşımı `CBA_fnc_waitAndExecute` ile tek seferliktir.

**`CfgRemoteExec`:** `config.cpp` iki fonksiyonu beyaz listeye ekler (`accessServerHandle` yalnızca sunucuya, `accessResult` herkese —
hosted MP'de host hem sunucu hem istemcidir). Sunucu kendi `description.ext`'inde `CfgRemoteExec` `mode = 1` kullanıyorsa ve bu iki fonksiyon
çalışmıyorsa, aynı iki sınıfı oraya da ekle.

**Güvenlik notu:** İstemcide arayüzün açılması tek başına koruma değildir. Gizli içerik (OPORD, INTSUM, Aşama 6) istemcide durmayacak;
sunucu doğrulamasından sonra sunucudan gönderilecek.

### Test

Tek başına test (editör → hosted MP → yerel dedicated + JIP): [`docs/TEST_ASAMA1.md`](docs/TEST_ASAMA1.md)

### Sorun giderme

| Belirti | Olası neden / çözüm |
|---------|---------------------|
| Başlangıçta "requires addon A3_Structures_F_Items_Electronics" | Vanilla yama adı oyun sürümünde farklı; RPT'deki mesajı bana ilet, `requiredAddons` düzeltilir |
| Ana menüde "Tactical C2 Network" ayar kategorisi yok | `@TC2` yüklenmemiş / PBO'da config hatası; RPT'de `tc2_main` ara |
| Terminali Eden'de bulamıyorum | F6 Objects → **Tactical C2 Network**; Zeus'ta addon'u aktive et (`units[]` listeli) |
| ACE menüsünde eylem yok | Terminale 2.5 m içinde bak; `TC2_terminal_enabled` açık mı; `[] call TC2_fnc_debugInfo` ile terminal görünüyor mu |
| Kartım var ama hep "kart bulunamadı" | `[] call TC2_fnc_debugInfo` → `aday` satırları ve `items`; gerçek sınıfı ayara yaz |
| "SUNUCU YANIT VERMEDİ" | Sunucuda `@TC2` yok ya da `CfgRemoteExec` kısıtı (yukarıya bak); sunucu RPT'sinde `[TC2][ACCESS]` var mı |
| Script hatası | `-showScriptErrors` ile başlat; `%LOCALAPPDATA%\Arma 3\*.rpt` içinde `TC2_` / `[TC2]` ara |
