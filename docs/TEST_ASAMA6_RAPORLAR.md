# Aşama 6b — Kartlar, tablet, roller ve raporlar (WARNO / SALUTE / SITREP / LACE) testi

Doktrin ve sınırlar: [`DOKTRIN_NOTLARI_RAPORLAR.md`](DOKTRIN_NOTLARI_RAPORLAR.md) (ATP 3-21.8: LACE, SALUTE, durum renkleri, WARNORD içeriği).

## Hazırlık (tek başına, host MP ya da Eden önizleme)

Mod: CBA + ACE + ACRE2 + @TC2. Terminal ve telsiz (ACRE2 radyo) hazır olsun. Debug konsolu **Local Exec**.

Kart / tablet ver (`debugGive`):
```sqf
["RED"] call TC2_fnc_debugGive;      // Kırmızı kart = Level 1
["BLUE"] call TC2_fnc_debugGive;     // Mavi kart = Level 2
["GOLD"] call TC2_fnc_debugGive;     // Siyah/Altın kart = Level 3
["TABLET"] call TC2_fnc_debugGive;   // saha tableti
["NONE"] call TC2_fnc_debugGive;     // tüm kart ve tableti al
```
Roller (Zeus: TC2 modülleri ya da değişken):
```sqf
player setVariable ["TC2_co", true, true];   // Bölük Komutanı (Level 3)
player setVariable ["TC2_s2", true, true];   // İstihbarat (Level 3, SALUTE doğrular)
player setVariable ["TC2_s4", true, true];   // Lojistik (Level 2 ya da 3, CBA ayarı)
```
Haritada başka bir lideri görmek için: tek başınıza kendi birliğiniz `SEN` olarak çizilir ve LACE paneline girmez. Tek başına test için **simüle eş** kullanın (Aşama 3'teki `debugNetPeer`); AI grubunun lideri harita liderlerinden biri olarak çizilir. Host'ta Local Exec, dedicated'ta Server Exec:
```sqf
TC2_p = (createGroup west) createUnit ["B_Soldier_F", player getPos [150, 0], [], 0, "NONE"];
(group TC2_p) createUnit ["B_Soldier_F", player getPos [152, 0], [], 0, "NONE"];   // grubu 2 kişi yap
[TC2_p, "ACRE_PRC343", 1, true] call TC2_fnc_debugNetPeer;                          // kendi telsiz tipiniz / kanalınızla aynı olsun
// o grup adına LACE raporu (haritada paneli denemek için):
[TC2_p, ["GREEN", "", "AMBER", "yarisi kaldi", "GREEN", "", "RED", "1 arac arizali"]] call TC2_fnc_debugLace;
```
Gerçek akışta ise rapor, liderin kendi terminal/tabletinden RAPOR sekmesiyle gönderilir (ikinci oyuncu ile).

## A. Kart seviyeleri (masa başı terminal)

1. `["NONE"]` ⇒ terminale giriş: **reddedilir** (kart yok).
2. `["RED"]` ⇒ terminale gir. OPORD sekmesinde yalnızca Level 1 bölümler; **RAPOR** sekmesi: *"Level 2 ve üstü içindir"*; CAS/TOPÇU formlarında yazma yok.
3. `["BLUE"]` ⇒ Level 2: gizli (Level 3) bölümler `[GİZLİ - Level 3]`; CAS 9-Line ve RAPOR yazabilir.
4. `["GOLD"]` ⇒ Level 3: her şey, OPORD/WARNO düzenlenebilir.
5. Kırmızı kartla `TC2_co` rolü verin ⇒ Level 3 (kadro seviyesi kartı geçer: max(kart, kadro)).

## B. Tablet kuralı

1. Kartı ve telsizi verin, tableti **almayın**: ACE self menüsünde **TC2 Saha Cihazı** görünmez.
2. `["TABLET"]` ⇒ eylem görünür. Grup lideri iken: tam kullanım (FIELD); tabletli bir er (başka birimde) VIEW.
3. Hava aracı mürettebatı (pilot) tabletsiz de CAS bildirim/alma (muaf).
4. Sunucuya tabletsiz bilgi göndermeyi deneyin (ör. `TC2_fnc_copFieldReport`) ⇒ sunucu reddeder.

## C. İzleme (VIEW) modu — er piyade

Lider olmayan, tabletli bir oyuncu (ya da `player` lider değilken ikinci istemci) saha cihazını açar:
* yalnızca **HARİTA** ve **OPORD** (Level 1 bölümler) sekmeleri etkin; diğerleri soluk,
* harita: dost/düşman işaretleri görünür; **LACE ve doğrulanmamış SALUTE yok**; DÜŞMAN PİYADE ve İŞARET SİL düğmeleri yok,
* sunucuya zorla istek (konsolla `copPlace`, `rptSend`) ⇒ `VIEW_ONLY` reddi (RPT: `[TC2][RAPOR] RED`).

## D. SALUTE → doğrulama → harita

1. Mavi kartlı lider (ya da FIELD tabletli grup lideri) **RAPOR** sekmesi ⇒ tür **SALUTE**; S = `12 kişi`, A = `ilerliyor`, L = Kendi konumum (ya da bir işaret), U = `BİLİNMİYOR`, T boş, E = `2 araç` ⇒ **RAPORU GÖNDER** ⇒ *"Rapor gönderildi (#1 SALUTE)"*.
2. S2/CO kullanıcısının terminalinde **RAPOR** sekmesi ⇒ gelen kutusu `#1 SALUTE ...`; ayrıntıda **DOĞRULANMAMIŞ**. **HARİTA** sekmesinde **soru işaretli** turuncu simge `SALUTE #1 ? 0 dk`.
3. **SALUTE'U DOĞRULA** ⇒ rapor *S2 DOĞRULADI*; haritada kırmızı **DÜŞMAN PİYADE** işareti oluşur, soru işareti kaybolur. Lider MicroDAGR'a `TC2 INF ...` waypoint'i düşer.
4. Doğrulama yetkisi olmayan kullanıcıda DOĞRULA düğmesi görünmez; zorla çağrı ⇒ `NOT_S2`.

## E. SITREP

RAPOR ⇒ SITREP: *Faaliyet*, *Düşman*, *Düşman KIA*, *Güvenlik*, *İkmal talebi*, *Notlar* (ATP 3-21.8 manga lideri → takım lideri raporu). Yalnızca *Faaliyet* zorunlu ⇒ gönder. Gelen kutusunda `KONUM` otomatik grid olarak eklenir.

## F. LACE ve harita

1. Lider **RAPOR ⇒ LACE**: dört satırda (Liquid, Ammunition, Casualties, Equipment) YEŞİL (85+) / AMBER (70-84) / KIRMIZI (50-69) / SİYAH (50 altı) / BİLİNMİYOR seç + kısa not ⇒ gönder.
2. Level 2+ kullanıcı (Mavi kart, S2, CO) **HARİTA ⇒ BİRİM / LACE**, haritada lider simgesine tıkla ⇒ panel: **GENEL: AMBER**, *DOĞRULANAN (sistem)* satırı (mevcut/ilk, yaralı, araç %), *LİDER RAPORU* satırları.
3. Lider simgesi LACE durumuna göre boyanır (yeşil / sarı / turuncu / gri) ve etiketi `[AMBER]` gibi eki taşır.
4. Birlik üyelerini öldürün/yaralayın (Zeus `setDamage`, ya da `{_x setDamage 1} forEach (units group aiLeader select [1,2])`) ⇒ en geç 5 sn'de **sayılar değişir**, lider yeşil beyan etse de **genel durum kötüleşir**.
5. LACE raporu olmayan birlik: panel *"Lider LACE raporu yok"* ve yine sistem sayıları.

## G. WARNO

OPORD sekmesi ⇒ belge türü listesinden **WARNO (Uyarı Emri)** ⇒ Level 3 ile **ŞABLON OLUŞTUR** ⇒ bölümleri düzenle ⇒ KAYDET. Mission dosyasından: `tc2_warno.sqf` ([örnek biçim `ornek_tc2_opord.sqf`](ornek_tc2_opord.sqf)).
11 bölümlü şablon (ATP 3-21.8 2-22 listesi): operasyon türü/yer, durum, görev, kuvvet, planlama rehberi, zaman çizelgesi, hareketler, ortak planlama, PCC/PCI/prova, CCIR, keşif görevleri. OPORD ile aynı seviye süzgeci: Level 3 bölüm (CCIR) Mavi kartta `[GİZLİ]`, rehber ve keşif görevleri Level 2.

## H. Dedicated sunucu

Aynı adımlar; `rpt` günlüklerinde `[TC2][RAPOR] SALUTE id=1 | gonderen=...` ve `DOGRULANDI SALUTE` satırları sunucuda görünür. İstemci RPT'sinde `Error` olmamalı.

## I. Arayüz: çerçeve, odak, harita araçları

1. **Çerçeve:** masa başı terminal = siyah çerçeveli dizüstü ekranı (alt çenede LED ve "TC2", altta klavye gövdesi); saha cihazı (ACE self menüsü) = kum rengi kılıflı tablet (üst/alt tutucu, kamera, yan tuşlar). Başlıkta canlı satır: `NW 300°  05:05  024 057  YÜK 12 m`.
2. **Yazı boyutu:** RAPOR ayrıntı kutusu normal boyutta olmalı (eskiden dev harf). Başka sekmede çok büyük/küçük metin görürseniz hangi sekme olduğunu yazın.
3. **Odak:** bir yazı kutusuna tıklayıp başka yere (siyah boş alana da) tıklayın; sekme düğmesi **beyaz kalmamalı**, açılır listeler ve düğmeler ilk tıkta çalışmalı. Boşa tıklamak artık hiçbir şey kapatmaz.
4. **Harita araçları** (HARİTA sekmesi, üst satır: DÜŞMAN PİYADE | İŞARET SİL | BİRİM / LACE | ÖLÇ | MERKEZ | KATMAN):
   * İmleci haritada gezdirin: sağdaki çubukta **grid, yükseklik (m), bana mesafe, yön (derece / mil)** canlı değişir.
   * **ÖLÇ** ⇒ iki noktaya tıklayın: sarı çizgi, `ÖLÇÜM 842 m  047° / 0835 mil  Δyük +12 m`. Üçüncü tık yeniden başlatır; ÖLÇ'e tekrar basınca kapanır.
   * **MERKEZ** ⇒ harita sizin konumunuza gider.
   * **KATMAN** ⇒ oyundaki harita işaretleri (Eden / Zeus / oyuncu işaretleri, alanlar, çizgiler) oyunun kendi sembolleriyle görünür; KAPALI ⇒ gizlenir. Denemek için normal Arma haritasına bir işaret koyun (çift tık) ya da Zeus ile işaret yerleştirin; 5 sn içinde terminal haritasında görünmeli.

## J. İşaret kategorileri ve çerçeve

1. **HARİTA**: üst satırda **İŞARET KOY**; altındaki satırda **kategori** ve **tür** listeleri. Kategoriler: PİYADE (piyade, keşif, motorize, mekanize), ZIRH, ATEŞ DESTEK (topçu, havan, hava savunma), HAVA (helikopter, uçak, İHA), KOMUTA / DESTEK (komuta, ikmal, bakım, servis, sağlık), DENİZ / TESİS, TEHLİKE / DİĞER (mayın/IED, pusu, bilinmeyen temas).
2. Kategori seç, tür seç ⇒ **İŞARET KOY** ⇒ haritaya tıkla ⇒ o türün **oyun NATO sembolü** (kırmızı; tehlikeler turuncu) ve adı + yaşı çizilir. MicroDAGR'a `TC2 <TÜR> <grid>` waypoint'i düşer.
3. CAS / TOPÇU / RAPOR / MEDEVAC sekmelerindeki işaret listelerinde tür adı doğru görünür (ör. `#3 DÜŞMAN TOPÇU grid ...`).
4. Sembollerden biri boş (görünmez) çıkarsa türünü ve kodunu yazın (oyunun simge dosyası farklı adlanıyor olabilir).
5. **Çerçeve:** masa başında **masaüstü monitör** (kalın siyah çerçeve, yuvarlak köşe, alt çene: LED + güç tuşu + "TC2", boyun ve ayak). Saha cihazında **kalın kum rengi kılıflı tablet** (yuvarlak köşe, siyah ekran kenarı, tutucular, yan tuşlar, kamera, sağda geri/çoklu görev tuşları). Köşeler ince yatay şeritlerle (çeyrek daire yayı) yuvarlatılır; ekranın kendi dört köşesi de çerçeve renginde şeritlerle kaplanır (içerik de yuvarlak köşeli görünür). Köşede hâlâ içe çökük/küçük görünen yer varsa ekran görüntüsüyle bildirin.
6. **Topçu:** AI topçu yok; oyuncu mürettebatlı batarya ya da `[TC2_gun] call TC2_fnc_debugArtyCrew;` (bkz. `TEST_ASAMA5B.md`).

## K. AI liderler haritada, MicroDAGR uyumu

1. **AI lider:** CBA `Ortak Harekat Resmi (COP)` ⇒ `AI grup liderlerini haritada göster` (varsayılan açık). Görünmesi için AI grubunun **lideri** envanterinde `TC2_Tablet` taşımalı (Eden başlatma alanı: `this addItem "TC2_Tablet"`; Zeus'ta sonradan: `(leader group cursorObject) addItem "TC2_Tablet"`). Aynı taraf ve **sizin telsiz menzilinizde** (ör. PRC343 = 500 m) olmalı. HARİTA'da `<çağrı adı> AI` etiketiyle dost simgesi, Level 2+ iseniz LACE rengiyle çıkar; BİRİM / LACE ile sayılar okunur (rapor beyanı yoktur).
2. Tabletsiz AI lider ya da menzil dışı AI: görünmez. Ayarı kapatınca hepsi kalkar (5 sn).
3. **MicroDAGR:** grup liderinin envanterinde `ACE_microDAGR` (ACE "MicroDAGR" eşyası) ve tablet olsun. Haritaya düşman işareti koyun ⇒ lider DAGR'ı açar (ACE: MicroDAGR) ⇒ **WAYPOINTS** sekmesinde `TC2 #5 INF 024057` gibi kayıtlar (işaret no, tür, grid). Oyuncunun kendi waypoint'leri (eklediyse) başta kalır. Bir `TC2 ...` waypoint'ini **SET WP** ile hedef seçin ⇒ yeni işaret eklenince/silinince hedef **aynı işarette kalmalı**, işaret silinirse hedef kalkmalı. Sadece grup lideri alır; er DAGR'a işaret almaz.
4. **Bakış oku:** HARİTA'da grup/takım liderlerinin (oyuncu ve tabletli AI) simgesinin önünde, baktıkları yönü gösteren bir **ok** olur (yayada gözün baktığı yön, araçta aracın yönü; 5 dereceye yuvarlanır, 5 sn'de bir yenilenir). Lideri döndürün: ok dönmeli; haritayı yakınlaştırınca ok simgeden aynı ekran uzaklığında kalmalı. Lider olmayan dostta ok yoktur.
5. Doğrulanmamış SALUTE noktaları DAGR'a **gitmez**; yalnızca işaret olanlar (S2/CO doğrulayınca) gider.

## L. Yazı tipi (EtelkaMonospacePro)

Terminal ve pilot penceresi oyunun eşit genişlikli **EtelkaMonospacePro** yazı tipiyle açılır (CBA `Arayüz ▸ Arayüz yazı tipi`, kişisel ayar, varsayılan açık; değişiklik pencere bir sonraki açılışında etkili olur). Harita etiketleri de aynı yazı tipini kullanır.
Kontrol edin: (1) tüm sekmelerde yazılar okunaklı mı, (2) **Türkçe karakterler** (İ ı ş ğ ç ö ü) kare/boşluk çıkmadan görünüyor mu, (3) düğme/etiketler taşıyor mu (eşit genişlikli yazı daha geniştir; taşan yeri bildirin, boyut küçültülür).
Karakterlerde sorun olursa ayarı kapatın; eski yazı tipine döner.

## M. Araç / helikopter içinde saha cihazı

Bir araca ya da helikoptere binin (yolcu veya pilot koltuğu fark etmez). ACE self menüsü (Sol Windows) ⇒ **TC2 Saha Cihazı** ⇒ "Saha cihazı bağlanıyor..." çubuğu tamamlanır ⇒ pencere açılır (ESC ya da KAPAT ile kapanır). Eskiden çubuk araç içinde hemen iptal oluyordu ("Kimlik doğrulama iptal edildi"). Hava aracı mürettebatı tablet taşımadan da açabilir; yer araçlarında tablet şartı sürer. Pencere modal olduğu için açıkken uçuş/sürüş tuşları pencereye gider; sürerken değil yolcu iken ya da sakin uçuşta kullanın.

## N. Çerçeve (gerçek doku)

**Saha cihazı artık GERÇEK DOKULU:** Samsung Tab Active5 tarzı sağlam tablet; kasa 8 parçalı `.paa` doku (4 köşe + 4 kenar; `addons/main/data/tab_*_ca.paa`). Doku, yükseklik haritası + ışıkla üretilen ince, düzgün kauçuk tanesi, kabartmalı ekran kenarı, siyah köşe koruyucular (kenarlarında silik aşınma), çok hafif toz filmi ve birkaç silik çizik içerir. Önceki "benek" çözümü dağınık/yapmacık görünüyordu; bu sürümde rastgele benek yok, doku tek parça ve tutarlı.
* Üretim: `tools/gen_textures.py` (doku), `tools/png2paa.py` (PNG → DXT5 `.paa`, kendi yazıcım; geri okuma ile doğrulanır). Kaynak PNG'ler: `tools/textures/`.
* **Kenarlar gerilir:** 9-dilim mantığı (köşeler sabit boy, kenarlar yalnızca uzun eksende gerilir); farklı ekran oranlarında çerçeve kalınlığı sabit kalır.
* **Sakinleştirilmiş doku:** tane, renk lekesi, toz ve çizik belirgin değil, "doku olduğunu bağırmayan" mat kauçuk görünümü (genlikler yaklaşık yarıya indi).
* **Ekran köşeleri:** artık basamak basamak şeritler değil; kenarları yumuşatılmış gerçek `.paa` maskeler (`tab_scr_*_ca.paa`, `desk_scr_*_ca.paa`, 4'er parça). Maske dokusu yoksa eski şeritli yedek kullanılır.
* **Ekran oturması / beyazlık:** parçalar arasındaki ve ekran kenarındaki piksel dikişlerinde oyun arka planının (açık gökyüzü) görünmesi engellendi: kasanın arkasına koyu zemin dikdörtgeni konuldu ve kenar parçaları köşelerle 0.0015 birim çakıştırıldı. Hâlâ beyaz çizgi görürseniz hangi kenar olduğunu (üst/alt/sol/sağ/köşe) ve ekran görüntüsünü gönderin.
* Küçük ayrıntılar (üst tuşlar, vidalar, kamera/sensörler, pogo noktaları, nervürler, yazı) doku üstünde kontrol olarak durur. Kontrol sayısı ~390'dan ~55'e indi (daha hızlı açılış).
* **YEDEK:** CBA `Arayüz ▸ gerçek dokulu saha cihazı çerçevesi` kapalıysa ya da dokular PBO'da yoksa (`fileExists`) kodla çizilen önceki çerçeve kullanılır.
* **DİKKAT (doğrulanmadı):** `.paa` dosyalarını kendi yazıcımla ürettim ve oyunda deneyemedim. Çerçeve **beyaz / boş / kırık** görünürse CBA ayarını kapatın ve RPT'deki doku hatası satırını gönderin. Ayrıca derleme aracınızın (pboProject / HEMTT) `addons/main/data/*.paa` dosyalarını PBO'ya kattığından emin olun.
* **Masa başı bilgisayar da gerçek dokulu:** monitör gövdesi (4 kenar parçası: üst, alt/çene, sol, sağ), ayak (boyun + taban), klavye (tuşlar kabartmalı, silik tuş yazılarıyla) ve fare ayrı `.paa` (`desk_*_ca.paa`); mat antrasit plastik, ince tane, üst-sol ışıklı kabartma. Çene tuşları, LED, yazı, kamera ve vidalar kontrol olarak ustte. Kontrol sayısı ~105'ten ~40'a indi. Aynı yedek mantığı: CBA ayarı kapalı ya da dosya yoksa kodla çizilen eski monitör.
* Üretim: `tools/gen_desk_textures.py`.
* **Önizleme:** `docs/onizleme/` (oyun görüntüsü değil; `gen_frame.py` önizlemeyi ve SQF gövdesini üretir).

## Bilinen sınırlar

* Raporlar sunucu belleğindedir (sunucu yeniden başlayınca silinir; son 3 saat, en çok 80 rapor).
* WARNORD biçim örneği (ATP 3-21.8 şekil 2-3) metinde görsel olduğu için okunamadı; bölüm başlıkları listeden türetildi.
* Çerçeve ve harita araçları yalnızca sqflint ile denendi; çerçeve oranları ve harita işaret çizimi oyunda ince ayar isteyebilir.
* Oyun harita işaretleri yalnızca **oyuncunun kendi haritasında gördükleri**dir; TC2 düşman işaretleri oyun işareti değildir ve normal haritada görünmez.
