# Doktrin notları (JP 3-09.3 ve JP 3-09)

Bu belge, projenin her aşamasının uyması gereken doktrin kurallarının **kısa özeti**dir. Kaynak: `doktrinler.md`
(depoda yoktur; 1,7 MB). Satır numaraları o dosyaya aittir ve ilgili metne hızlı dönmek içindir.

Dosya yapısı: JP 3-09.3 *Close Air Support* (08 Temmuz 2009) başta (satır 1 – ~22100), JP 3-09 *Joint Fire Support*
(30 Haziran 2010) sonra (satır ~44195'ten itibaren). Dosyada bazı bölümler iki kez geçiyor (ör. satır 1557 ve 23653 aynı paragraf).

## Kontrol türleri (Type 1 / 2 / 3) — satır 1145–1170, 12177–12700

| Tür | Ne zaman | Notlar |
|-----|----------|--------|
| **Type 1** | JTAC, **her saldırı için** hem uçağı hem hedefi **görsel** olarak görmeli | Her zaman **BOT** (uçak hedefi ya da işareti görmeli). CAS brifinginden sonra Type 2/3'e geçilmemeli. |
| **Type 2** | JTAC **tek tek saldırıları** kontrol etmek ister ve şunlardan biri/birkaçı geçerlidir: uçağı bırakış anında göremiyor, hedefi göremiyor, uçak işareti/hedefi bırakıştan önce göremiyor | BOT veya BOC olabilir. |
| **Type 3** | JTAC, belirli kısıtlar altında **tek angajmanda birden çok saldırıya** izin verebilmek ister (aynı görme koşulları) | BOT veya BOC olabilir. Tüm hedefleme verisi ilgili ateş onay makamı üzerinden koordine edilir. TGO ile karıştırılmamalı. |

- JTAC kontrol türünü her an değiştirebilir (komutanın çerçevesinde, ateş onay makamıyla koordineli); ama bu değişiklik
  Type 1/2 için **"IN" çağrısından**, Type 3 için **"commencing" çağrısından önce** yapılmalıdır. Sonra gerekirse saldırı iptal edilip yeniden brifing verilir. **JTAC iptal yetkisini her zaman elinde tutar.** (12775–12790)

## BOT / BOC — satır 12797–12960

- Her CAS angajmanı BOT (*bomb on target*) veya BOC (*bomb on coordinate*) tir; tüm mühimmat için geçerlidir.
- BOT/BOC ifadesini brifingde **söylemek zorunlu değildir**; amaç JTAC niyetinin net olmasıdır. İsteniyorsa 9-Line'dan hemen önce
  kontrol türüyle birlikte ("Type 2 in effect, bomb on coordinate, advise when ready for 9-line") veya remarks/restrictions içinde söylenir.
- **BOC**: uçak hedefi görmek/yakalamak zorunda değildir; koordinat sistem noktasına girilir; **uçak ekibi koordinatı geri okuduktan sonra değiştirmez**;
  geri okuma uçağın silah/seyir sisteminden yapılır.

## 9-Line CAS brifingi — Figure V-14, satır 13685–13900

Önsöz: `"<uçak çağrı adı>, bu <JTAC çağrı adı>, Type <1|2|3> kontrol"` (isteğe bağlı BOC/BOT ifadesi).
**Satır numaraları iletilmez**; 9 satır sırayla, parça parça değil tek seferde verilir.

| # | Satır | İçerik / birim |
|---|-------|----------------|
| 1 | IP/BP | Başlangıç noktası (sabit kanat: IP, döner kanat: BP) |
| 2 | Heading | IP/BP → hedef, **derece manyetik**; kısıt varsa **offset sol/sağ** |
| 3 | Distance | IP → hedef **nm (onda bir hassasiyet)**; BP → hedef **metre (100 m'ye yuvarlanmış)** |
| 4 | Target elevation | **feet MSL** — *zorunlu geri okuma* |
| 5 | Target description | Uçak ekibinin tanıyacağı kadar net ve kısa |
| 6 | Target location | Grid (**100.000 m grid kimliği dahil**), enlem/boylam, referanstan ofset veya görsel tarif; **datum belirtilmeli** — *zorunlu geri okuma* |
| 7 | Mark type + code | Duman / lazer / IR; lazer ise **4 haneli kod** |
| 8 | Friendlies | En yakın dost: **metre + kardinal/alt-kardinal yön** (N, NE, E, SE, S, SW, W, NW), hedeften |
| 9 | Egress | Kardinal yön ve/veya kontrol noktası; "Egress" kelimesiyle başlar |

**Remarks** (uygunsa): lazer-hedef hattı (LTL, derece manyetik), istenen mühimmat/etki, bastırma (tehdit/yer/tür), aktif GTL, havacılık tehlikeleri,
hava durumu, ek hedef bilgisi, gece görüş kabiliyeti, zaman kısıtları, dost işareti.
**Restrictions** (uygunsa; **hepsi geri okunur**): son saldırı yönü, ACA'lar, **danger close (komutanın baş harfleriyle)**, TOT/TTT.

Geri okuma: satır **4**, satır **6** ve tüm **kısıtlar** her üç kontrol türünde zorunludur; JTAC ek öğeler de isteyebilir.

## Roller — satır 1337–1345, 2317–2332, 3299–3312

- **JTAC / FAC(A)**: sertifikalı; terminal saldırı kontrolü (TAC) yetkisi **yalnızca bunlarda**.
- **JFO** (Joint Fires Observer): yüzeyden yüzeye atışları isteyip ayarlayabilir, Type 2/3 CAS için hedefleme verisi sağlayabilir, TGO yapabilir;
  **CAS sırasında terminal saldırı kontrolü veremez**.
- **TGO** (Terminal Guidance Operations): hedefe yaklaşan uçak/silaha ek bilgi sağlayan eylemler; **TAC ile aynı şey değildir**.

## Tasarıma etkisi (öneriler, onayına açık)

- **Aşama 5 (9-Line formu):** alanlar yukarıdaki tabloyla birebir; sunucu tarafı doğrulama: lazer kodu 4 hane, heading 0–359, satır 4 ve 6 için geri okuma
  adımı, Type 1 seçilirse BOC seçeneği kapalı (Type 1 her zaman BOT), kontrol türü değişimi "IN"/"commencing" sonrası kilitli.
- **Aşama 6 (yetki seviyeleri):** JTAC/FAC(A) = TAC yetkili (9-Line'ı yayınlayabilen), JFO = istek/hedef verisi sağlar ama kontrol veremez.
  Level 1/2/3 eşlemesi Aşama 6'da birlikte netleştirilecek.
