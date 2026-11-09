# Askeri teknoloji uyum (entegrasyon) katmanı — plan

Amaç: terminal / saha tableti, oyundaki (vanilla + ACE + ACRE) askeri teknolojilerle **birlikte çalışsın**; bilgiyi oyuncudan istemek yerine mümkün olduğunca oyundan okusun.
Kapsam dışı (ayrı planlı kalemler): **lojistik (S4)** ve **UAV**. Bu belge ikisini içermez.

Durum: **PLAN** (kodlanmadı). API'lerin tamamı bilgimden yazıldı, oyunda doğrulanmadı; her kalemde "doğrulanacak" notu var.

## Sizin istedikleriniz

### 1. İşaretlenen lazerler görünsün (lazer işaretleme)
* **Ne:** Lazer hedef gösterici (LTD) kullanan askerin işaretlediği nokta HARİTA'da lazer simgesi olarak görünür; **lazer kodu** (4 haneli) ve **LTL (laser-to-target line, lazerden hedefe yön)** çizilir. 9-Line CAS formundaki *Remarks / kodlar* alanıyla ilişkilendirilir.
* **Doktrin dayanağı (yüklü JP 3-09.3):** lazer işaretleme, 4 haneli lazer kodu ve LTL'nin CAS brifinginde verilmesi, "LASER ON" / "SPARKLE" çağrıları, lazer kodunun teyidi, PRF kodları, LST'li uçak (laser spot tracker).
* **Oyundan okuma (doğrulanacak):** vanilla `laserTarget <asker>` (işaretleyen birimin hedef nesnesi), ACE lazer işaretleyici (`ace_laser`; kodlar ACE'te ayarlanır). Lazer açık mı olayı olmadığı için sunucuda **seyrek yoklama** (2-3 sn) gerekir; yalnızca lazer işaretleyici taşıyan birimler taranır (performans).
* **Çıktı:** (a) haritada lazer noktası + kod + işaretleyen çağrı adı, (b) pilot/mürettebata ACE self menüsünde "LAZER: kod 1688, LTL 047°, 842 m", (c) LASER ON / SPARKLE olay günlüğü.

### 2. Helikopter pilotu yardımcısı
* **Ne:** Hava aracındaki oyuncu için tek ekranlık özet (ACE self menü + kısa pencere): gelen CAS 9-Line / MEDEVAC talepleri, hedef grid + irtifa/yön, **dost birimler** (COP), lazer noktası ve kodu, alım yeri (LZ) bilgisi, danger-close uyarısı.
* **Kullanım:** uçuşu bölmemek için bildirim + bip (mevcut desen); pencere elle açılır. Gerekirse yalnızca konuşma/sesli bildirim.
* **Mevcut altyapı:** `casPilotOpen`, MEDEVAC ACE menüsü, COP. Yeni olan: pilot tarafı birleşik özet ve lazer.

## Önerilen ek kalemler (lojistik ve UAV hariç)

Öncelik sırası benim önerimdir; hangilerinin alınacağına siz karar verirsiniz.

| # | Kalem | Ne yapar | Doktrin / dayanak | Zorluk |
|---|-------|----------|-------------------|--------|
| 3 | **Ateş destek koordinasyon ölçüleri** | Haritada NFA (ateş yasak alanı), RFA (kısıtlı ateş alanı), kill box, FSCL benzeri çizgi; CAS / CFF hedefi yasak alana düşerse FDC ve JTAC'a uyarı ya da ret | JP 3-09, JP 3-09.3 (yüklü; kill box, NFA, RFA, FSCL tanımları) | Orta |
| 4 | **Dost yakınlığı / danger close otomatik** | CAS ve CFF hedefi, COP'taki dost birime X m yakınsa otomatik DANGER CLOSE uyarısı (CFF'de zaten kısmen var; CAS'a ve COP'a bağlanır) | JP 3-09.3, ATP 3-09.30 (danger close 600 m kuralı bizde uygulanıyor) | Kolay |
| 5 | **Hava savunma uyarı durumu ve silah kontrol durumu** | CO bir alan/hava sahası için durumu ilan eder (kırmızı / sarı / beyaz; silah serbest / sıkı / bekle); tüm terminallerin başlığında görünür, hava araçlarına bildirilir | JP 1-02: "air defense warning condition", "weapons control status" (yüklü) | Kolay |
| 6 | **Gece modu** | Gece / NVG iken terminal parlaklığı ve renkleri kısılır (NVG uyumlu); kendi saatinde otomatik | ergonomi (doktrin değil) | Kolay |
| 7 | **Oyun veri bağı (datalink) temasları → COP** | Arma'nın kendi sensör veri bağıyla paylaşılan düşman temasları (araç/uçak sensörleri) "doğrulanmamış temas" olarak haritaya düşer; S2 doğrulayınca düşman işareti olur (SALUTE mantığı) | bilgi güvenirliği (bizim kural) | Orta (doğrulanacak: `listRemoteTargets` / `targetsQuery`) |
| 8 | **Telemetre ile otomatik CFF / CAS doldurma** | ACE telemetre ya da lazer mesafe ölçer ile ölçülen hedef (mesafe + azimut) CFF "polar" alanlarına ve 9-Line satır 6'ya otomatik yazılır | ATP 3-09.30 (polar, FO düzeltmesi) | Orta (doğrulanacak: ACE telemetre olayı) |
| 9 | **PACE haberleşme planı** | OPORD haberleşme bölümüne PACE (birincil / alternatif / acil durum / son çare) kanal planı; telsiz menzili kopunca terminal bir sonraki planı önerir | yüklü dokümanlarda PACE geçer (ATP 3-21.8 vb.) | Orta |
| 10 | **CAS–topçu çakışma önleme (deconfliction)** | CFF'nin atış-hedef hattı / uçuş süresi ile CAS'ın uçak koridoru çakışırsa FDC ve pilota uyarı; TOT (time on target) eşleştirme | JP 3-09.3, JP 3-09 (deconfliction) | Zor |
| 11 | **IR strobu / işaretleme gösterimi** | Dost IR strobu, duman, piroteknik işaretlerin (9-Line satır 7 "mark") haritada görünmesi; pilota "işaret: duman, kırmızı" | JP 3-09.3 (işaretleme) | Orta |
| 12 | **Olay günlüğü ve AAR** | Sunucuda zaman çizelgesi (talepler, atışlar, raporlar, kabuller) ve görev sonu özeti (ekran + dosya) | genel iyi uygulama | Kolay-orta |

## Mimari ilkeler (hepsi için)
* Sunucu yetkili, MP-doğru (remoteExec beyaz listesi, gönderen denetimi); istemcide kare başı döngü yok.
* Okumalar **olay tabanlı** ya da seyrek yoklama (2-5 sn) ve yalnızca ilgili birimlerde.
* Bilgi güvenirliği: oyundan okunan veri "sistem doğrulaması" sayılır; oyuncu beyanı ayrı etiketlenir.
* Her kalem CBA ayarıyla kapatılabilir.
