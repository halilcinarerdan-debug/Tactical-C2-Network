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
| 5 | Dijital 9-Line CAS talebi (Type 1/2/3, BOT/BOC, zorunlu geri okuma, abort) | ✅ hazır (test bekliyor) |
| 5B | Topçu: gözlemci CFF + oyuncu FDC operatörü (ATP 3-09.30), AI/oyuncu bataryası | ✅ hazır (test bekliyor) |
| 6a | **OPORD** (JP 3-0): beş paragraf, Level 1/2/3 yetki, sunucuda süzme | ✅ hazır (test bekliyor) |
| 6b | **Raporlar** (SALUTE / SITREP / LACE) + WARNO; kart seviyeleri (Kırmızı/Mavi/Altın), CO/S2/S4 rolleri, saha tableti, izleme modu, haritada LACE | ✅ hazır (test bekliyor) |
| 6c | INTSUM + lojistik talepleri (S4) | ⏳ |

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
        fn_debugGive.sqf                 TEST: kırmızı/mavi/altın kart ve tablet ver / al
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
    arty/                                5B. aşama (topçu: CFF / FDC)
        fn_artyValidate / artyLines      CFF doğrulaması (ATP 3-09.30) ve üç aktarım gösterimi (saf)
        fn_artyCorrect / artyResolvePos  düzeltme (deviation/range/HOB) ve GRID / POLAR / SHIFT çözümü
        fn_artySendCff / artyPoll        [SUNUCU] CFF gönder (danger close 600 m denetimi), sekme verisi
        fn_artyFdcAction                 [SUNUCU] FDC: ACCEPT (MTO, menzil, mühimmat), REJECT, SHOT/SPLASH/COMPLETE, CHECK
        fn_artyObsAction                 [SUNUCU] gözlemci: CORRECT / REPEAT / FIRE / CHECK / EOM
        fn_artyExecute / GunFired / Complete  [SUNUCU] atış (AI: commandArtilleryFire; oyuncu: ateş emri), SHOT/SPLASH/ROUNDS COMPLETE
        fn_artyBatteries / artyIsGun     [SUNUCU] topçu araçlarını otomatik bul, batarya olarak grupla
        fn_artyUi* / artyObsBuild / artyFdcBuild  [İSTEMCİ] TOPÇU ve FDC sekmeleri
    opord/                               6a. aşama (OPORD, yetki seviyeleri)
        fn_userLevel.sqf                 asker seviyesi (TC2_level > rütbe / grup lideri / rol)
        fn_opordTemplate.sqf             beş paragraf şablonu (JP 3-0'a göre)
        fn_opordLoad / opordSet          [SUNUCU] mission'daki tc2_opord.sqf'i yükle / belgeyi tanımla
        fn_opordPoll.sqf                 [SUNUCU] belgeyi SEVİYEYE GÖRE SÜZEREK gönder (gizli bölüm metni istemciye gitmez)
        fn_opordEdit.sqf                 [SUNUCU] ACK / SAVE / TEMPLATE (Level 3)
        fn_opordBuild / opordUi*         [İSTEMCİ] OPORD sekmesi
    cas/                                 5. aşama (dijital 9-Line CAS) + roller (hasRole, Zeus modülleri)
        fn_casValidate.sqf               doktrin doğrulaması (19 alanlı form; sunucu karar verir, istemci ön kontrol)
        fn_casLines / casGrid            9 satırı okunur biçimde yaz; 10 haneli grid (ACE)
        fn_casCompare.sqf                zorunlu geri okuma karşılaştırması (satır 4, 6, kısıtlar)
        fn_casSend / Poll / Abort        [SUNUCU] gönder, CAS sekmesi verisi, iptal
        fn_casReadback / ApplyReadback   [SUNUCU] pilot geri okuması, sonuç dağıtımı
        fn_casTargets.sqf                [SUNUCU] alıcılar: aynı ağ + menzil + hava aracı
        fn_casUi*.sqf                    [İSTEMCİ] JTAC formu (CAS sekmesi)
        fn_casPilot*.sqf                 [İSTEMCİ] pilot penceresi (ACE self menü)
        fn_debugCasPilot.sqf             TEST: AI'ı simüle CAS pilotu yap
docs/
    DOKTRIN_NOTLARI.md                   doktrinden çıkan kurallar (9-Line, Type 1/2/3, BOT/BOC, roller)
    TEST_ASAMA1.md                       tek başına test: editör, hosted MP, yerel dedicated
    TEST_ASAMA2.md                       arayüz testi
    TEST_ASAMA3.md                       ağ/mesajlaşma testi (tek kişilik, simüle eş)
    TEST_ASAMA4.md                       COP / işaret / MicroDAGR testi
    TEST_ASAMA5.md                       9-Line CAS testi (tek kişilik)
    TEST_ASAMA5B.md                      topçu CFF / FDC testi (tek kişilik)
    TEST_ASAMA6_OPORD.md                 OPORD / seviye filtresi testi
    DOKTRIN_NOTLARI_OPORD.md             JP 3-0: emrin içeriği (görev, niyet, CCIR, CONOPS, ROE)
    ornek_tc2_opord.sqf                  mission klasörüne konacak örnek OPORD dosyası
    DOKTRIN_NOTLARI_TOPCU.md             ATP 3-09.30 özeti (call for fire, düzeltme, danger close)
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

## Aşama 6b – Raporlar (SALUTE / SITREP / LACE), WARNO, kartlar, tablet

**RAPOR** sekmesi (SALUTE / SITREP / LACE), **WARNO** (OPORD sekmesinde belge türü) ve harita üzerinde **LACE**. Doktrin notu ve sınırlar:
[`docs/DOKTRIN_NOTLARI_RAPORLAR.md`](docs/DOKTRIN_NOTLARI_RAPORLAR.md) — dayanak **ATP 3-21.8** (LACE, SALUTE, durum renkleri 85/70/50, WARNORD içeriği) ve JP 1-02 tanımları.

| Konu | Kural |
|------|-------|
| Kartlar | **Kırmızı = Level 1** (kendi görevleri), **Mavi = Level 2** (gizli belge yok; 9-Line, CFF, rapor yazar), **Siyah/Altın = Level 3** (her şey). Masa başında seviye = max(kart, kadro). |
| Kadro | **CO** ve **S2 = Level 3**, **S4 = Level 2 ya da 3** (CBA). Zeus/Eden modülleri ya da `TC2_co` / `TC2_s2` / `TC2_s4` değişkeni. |
| Saha tableti | Hava aracı mürettebatı dışında herkes, terminale bilgi **göndermek ve almak** için envanterinde `TC2_Tablet` taşımalıdır (CBA'dan değiştirilebilir). |
| Tablet kullanımı | Grup/takım lideri, JTAC, gözlemci, FDC: **tam** (Level 2'ye kadar). Er: **izleme** (yalnızca harita ve işaretler); LACE ve raporlar görünmez, yazma sunucuda reddedilir. |
| SALUTE | Lider gönderir; **S2/CO doğrulayana** kadar haritada soru işaretli simge; doğrulanınca düşman işareti. |
| LACE | Sistemin doğruladığı sayılar (mevcut, yaralı, araç hasarı) + liderin beyanı (L/A/C/E rengi); harita lider simgesi en kötü duruma göre boyanır (ATP 3-21.8 renkleri: yeşil 85+, amber 70-84, kırmızı 50-69, siyah 50 altı). Yalnızca Level 2+. |

Test: [`docs/TEST_ASAMA6_RAPORLAR.md`](docs/TEST_ASAMA6_RAPORLAR.md). Test yardımcısı: `["BLUE"] call TC2_fnc_debugGive;` (RED / BLUE / GOLD / TABLET / NONE).

### Arayüz: çerçeve ve harita araçları (ATAK'tan esinlenen)

Masa başı terminal dizüstü çerçevesi, saha cihazı kılıflı tablet çerçevesi içinde açılır; başlıkta canlı yön / saat / grid / yükseklik satırı vardır.
HARİTA sekmesi: imleç altı canlı **grid + yükseklik + mesafe + yön (derece/mil)**, **ÖLÇ** (iki nokta arası mesafe / yön / yükseklik farkı), **MERKEZ**,
**KATMAN** (oyun harita işaretleri oyunun kendi sembolleriyle). Hepsi istemcide yerel hesap; ağ yükü yok, kare başına döngü yok (çizim olayı + 10 Hz kısıtlı imleç olayı).

## Aşama 6a – OPORD (yetki seviyeli operasyon emri)

**OPORD** sekmesi: beş paragraf düzeninde operasyon emri (Situation, Mission, Execution, Sustainment, Command and Signal + görev organizasyonu + ateş eki).
Doktrin: JP 3-0 ([`docs/DOKTRIN_NOTLARI_OPORD.md`](docs/DOKTRIN_NOTLARI_OPORD.md)).

| Konu | Kural |
|------|-------|
| Seviyeler | **Level 1** herkes; **Level 2** grup lideri, JTAC / gözlemci / FDC ya da rütbe ≥ eşik; **Level 3** komuta (rütbe ≥ eşik). Objede `TC2_level` (1-3) rütbeyi geçersiz kılar. Eşikler CBA'da. |
| Gizlilik | **Sunucuda süzülür:** her bölümün gereken seviyesi vardır (varsayılan: düşman, manevra, ateş = 2; **CCIR ve haberleşme = 3**, JP 3-0: CCIR yalnızca komutana aittir). Yetersiz seviyede bölümün **metni istemciye hiç gönderilmez**, yalnızca başlık ve gereken seviye görünür. |
| Düzenleme | yalnızca **Level 3**: ŞABLON OLUŞTUR (belge yokken), bölüm metni ve seviyesi düzenle, KAYDET (sürüm artar; ağa "OPORD güncellendi" bilgi satırı). |
| Onay | herkes OKUDUM / ANLADIM der (sürüm başına); Level 3 sayıyı görür. |
| Mission'dan yükleme | mission klasöründe `tc2_opord.sqf` ([örnek](docs/ornek_tc2_opord.sqf)) ⇒ sunucu mission başında yayımlar. |
| Erişim | fiziksel terminalde telsiz gerekmez (belge üstedir); saha cihazında telsiz ağı gerekir. |

**Sınırlar (dürüstçe):** JP 3-0 beş paragraf alt başlıklarını vermez (JP 5-0'dadır); alt başlıklar ABD Ordusu düzenindendir ve doğrulanmamıştır.
Başlık/DTG/etiketin oyun içi düzenlenmesi yok (mission dosyası ya da `TC2_fnc_opordSet` ile). Belge sunucu belleğindedir (sunucu yeniden başlayınca mission dosyasından gelir; oyun içi düzenlemeler kalıcı değildir).
Sonraki: INTSUM ve lojistik talepleri (aynı seviye altyapısıyla).

Test: [`docs/TEST_ASAMA6_OPORD.md`](docs/TEST_ASAMA6_OPORD.md).

## Aşama 5B – Topçu (CFF / FDC)

**TOPÇU** sekmesi gözlemcinin (FO/JFO; JTAC de olabilir) call for fire formu ve görev denetimi; **FDC** sekmesi FDC operatörünün ekranıdır. Sahadan **Saha Cihazı** ile de kullanılır.
Doktrin: ATP 3-09.30 ([`docs/DOKTRIN_NOTLARI_TOPCU.md`](docs/DOKTRIN_NOTLARI_TOPCU.md)).

| Konu | Kural |
|------|-------|
| Roller | **Gözlemci** (`TC2_observer`, rol açıklaması FO/JFO/FIST/OBSERVER, sınıf listesi) ve **FDC** (`TC2_fdc`, rol açıklaması FDC/FDO, sınıf listesi); Zeus'ta **Gözlemci Ata / Kaldır** ve **FDC Operatörü Ata / Kaldır** modülleri. |
| CFF | Altı eleman, üç aktarım (gözlemci kimliği + uyarı emri / konum / tanım + angajman + kontrol). Görev: ADJUST FIRE, FIRE FOR EFFECT, SUPPRESS, IMMEDIATE SUPPRESSION / SMOKE. Konum: **GRID** (HARİTA işareti), **POLAR**, **SHIFT** (işaret ya da önceki hedef no). Doğrulama sunucuda. |
| FDC | **Oyuncu** operatör: CFF'i kuyrukta görür, batarya seçer, MTO ile KABUL eder ya da REDDEDER (CFF bir istektir). Menzil (`inRangeOfArtillery`) ve mühimmat denetlenir; hedef numarası verilir. |
| Komutlar | MTO, SHOT, SPLASH (yüksek açı / hava gözlemcisi), ROUNDS COMPLETE, AT MY COMMAND (IS READY → FIRE), CHECK FIRING, END OF MISSION (+ RECORD AS TARGET). |
| Düzeltme | Gözlemci düzeltmeyi kendisi gözleyip gönderir: DIRECTION, LEFT/RIGHT, ADD/DROP, UP/DOWN, ADJUST/FFE, REPEAT. Sunucu OT hattına göre nişan noktasını hesaplar. |
| DANGER CLOSE | hedef dostlara **600 m** içindeyse bildirilmeden CFF kabul edilmez; danger close'ta menzil düzeltmesi en çok 100 m (creeping). |
| Toplar | topçu araçları **otomatik** bulunur (artillery computer / StaticMortar / CBA sınıf listesi); aynı mürettebat grubu = bir batarya. **AI mürettebat** CBA'dan BLUFOR / OPFOR / INDFOR için açılıp kapatılır (`commandArtilleryFire`); **oyuncu mürettebata** ateş emri bildirimi gider, FDC SHOT / SPLASH / COMPLETE'i elle girer. |

**Sınırlar:** mermi düşüşünü sistem gözlemlemez (gözlemci kendisi gözler); AI topları sunucuda yerel olmalıdır; HOB / tapa tipi ve yeni mühimmat seçenekleri (laser grid, kayıt atışı, TOT, aydınlatma koordinasyonu, sheaf) bu sürümde YOK
(temel set). Yüksek açı/alçak açı yalnızca bilgi olarak taşınır; atış, aracın kendi silahına bağlıdır. ACE'in Mk6 havan tabloları AI atışını etkilemez; oyuncu mürettebat kendi tablolarını kullanır.

Test: [`docs/TEST_ASAMA5B.md`](docs/TEST_ASAMA5B.md).

## Saha Cihazı (laptop olmadan)

Sahadaki birlikler (JTAC, gözlemci) formları ve mesajları **laptop olmadan** kullanır: ACE self menüsü ⇒ **TC2 Saha Cihazı** ⇒ terminalle **aynı pencere**
(ANA mesajlaşma, HARİTA, CAS 9-Line, TOPÇU CFF, FDC). Başlık `TC2 SAHA CİHAZI | SAHA <çağrı adı>`.

| Konu | Kural |
|------|-------|
| Erişim | Terminalde olduğu gibi sunucu karar verir; farkı: **mesafe ve kimlik kartı aranmaz** (varsayılan). Yine geçerli: canlı/bilinçli, **aktif telsiz ve ağ kuralları**, rol (JTAC / gözlemci). |
| Sıkılaştırma (CBA) | `Saha cihazı aktif`, `Saha cihazı da kimlik kartı istesin`, `Saha cihazı eşyası` (doluysa envanterde olmalı). |
| Üs görünürlüğü | Sahadan gönderilen formlar (9-Line gönderildi, geri okuma sonucu, iptal) aynı ağdaki **terminal ve saha cihazı günlüklerine** `CAS #id …` bilgi satırı olarak düşer. |
| Teknik | Saha modunda "terminal" olarak birimin kendisi verilir (`accessCheck`: `_terminal isEqualTo _unit`); diğer tüm katmanlar (ağ, COP, CAS) değişmeden çalışır. |

## Aşama 5 – Dijital 9-Line CAS

**CAS** sekmesi tek ekranlı 9-Line formudur (JP 3-09.3, Figure V-14 sırası). JTAC doldurur, ağdaki pilota gönderir; pilot ACE self menüsünden
(**uçak içinde de**) açıp **zorunlu geri okumayı** yapar; sonuç JTAC'a renkli satırlarla döner.

| Konu | Kural |
|------|-------|
| Yetki | yalnızca JTAC; sunucu `TC2_fnc_isJtac` ile karar verir. JTAC sayılma yolları (öncelik sırasıyla): **(1) açık atama**: **Zeus modülü** "JTAC Ata / Kaldır" (birimin üzerine koy, aç/kapa) ya da Eden modülü/`this setVariable ["TC2_jtac", true, true];` — `false` sınıf/rol JTAC olsa bile yetkiyi kaldırır; **(2) Eden rol açıklamasında** `JTAC` veya `FAC`; **(3) sınıf listesi** (CBA ayarı, varsayılan vanilla Recon JTAC). ACE'in kendi bir JTAC/pilot rolü yoktur. |
| Pilot | ayrı rol gerekmez: JTAC'ın ağında, menzilde ve **hava aracında** oturan herkes alıcı olabilir (sabit kanat = Plane, diğerleri = döner kanat). |
| Alıcı | JTAC ile aynı telsiz tipi + kanal + menzilde ve hava aracında (Plane = sabit kanat, diğerleri = döner kanat). Gönderim, Aşama 3 ağ kontrolünden geçer ("BAĞLANTI YOK"). |
| Doktrin doğrulaması | **sunucuda**: Type 1 ⇒ yalnız BOT; heading 0-359; mesafe sabit kanatta nm (0.1), döner kanatta m (100 m katı); lazerde 4 haneli kod; dostlar m + kardinal yön; danger close komutan baş harfleriyle; serbest metin temizlenir. |
| Hedef konumu | HARİTA sekmesindeki düşman işaretlerinden seçilir; yükseklik (ft MSL) otomatik; konum 10 haneli grid, datum "ARMA grid". |
| Geri okuma | satır 4, satır 6 ve verilmiş tüm kısıtlar (doktrin). Sunucu karşılaştırır; TAMAM/HATA + doğru değer JTAC ve pilota. Yanlışsa tekrar. |
| İptal | JTAC her zaman iptal edebilir (doktrin); pilot bilgilendirilir. |
| Pilot bildirimi | bildirim + kısa bip; pencere **kendiliğinden açılmaz** (uçuşu bölmez). |
| Güvenlik/performans | tüm kararlar sunucuda, `remoteExecutedOwner` gönderen doğrulaması, 3 sn aralık, `[TC2][CAS]` RPT kaydı. Sekme dışında ek maliyet yok. |

**Kapsam dışı (sonraki küçük aşama):** "cleared to engage" / "cleared hot" izinleri, "IN" çağrısı sonrası kontrol türü değiştirme kilidi (doktrin: Type değişimi
Type 1/2'de "IN", Type 3'te "commencing" çağrısından önce yapılmalı). Şu an: form, gönderim, geri okuma, iptal.

**Bilinen sınırlar:**
- Konum 10 haneli oyun grid'idir (doktrinin istediği 100.000 m grid kimliği + MGRS yok; Arma'da yoktur). Datum satırında belirtilir.
- Geri okuma, pilotun değerleri yazması şeklindedir (ses yerine); amaç doktrindeki doğrulama adımını işletmektir.
- Pilot penceresi modal diyalogdur: açıkken uçuş tuşları pencereye gider. Sakin uçuşta veya ikinci pilotla kullanılmalı.
- Pilotun hava aracında olup olmadığı sunucuda `vehicle _unit isKindOf "Air"` ile bakılır; farklı mod araçlarında sınıf kalıtımı değişebilir.

Test: [`docs/TEST_ASAMA5.md`](docs/TEST_ASAMA5.md).

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
