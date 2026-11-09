# Askeri teknoloji uyum katmanı — sade sürüm

İlke: **fazla "uzaylı" özellik yok, arayüz karmaşıklaşmıyor.** Yalnızca gerçek saha sistemlerinde (ATAK / BFT / JTAC tableti) olmazsa olmaz olanlar, **yeni sekme ya da düğme eklemeden** mevcut ekranlara bindirilir. Lojistik ve UAV ayrı planlı kalemlerdir, burada yok.

## Eklenenler (kodlandı, oyunda doğrulanmadı)

| Özellik | Davranış | Arayüz değişikliği |
|---------|----------|--------------------|
| **CAS / CFF / MEDEVAC noktaları haritada** | Aktif CAS hedefi (turuncu "yok et" simgesi; lazer işaretliyse `LAZER 1688` etiketi), CFF hedefi (sarı), MEDEVAC alım yeri (yeşil tıbbi simge) HARİTA'da görünür. Hava aracındaki pilot da saha cihazını açıp görür: **pilot yardımcısı** budur. Lazer kodu 9-Line satır 7'den gelir; canlı lazer izi yoktur. | Yok (HARİTA'ya bindirme) |
| **CAS danger close denetimi** | Sunucu, hedefe yakın dostu (COP) bulursa ve satır 17'de komutan baş harfleri yoksa CAS talebini REDDEDER; baş harfler varsa pilota "DANGER CLOSE: dost X m" uyarısı gider. Eşik CBA `TC2_cas_dangerClose` (varsayılan 600 m). Topçuda 600 m zaten vardı. | Yok |
| **Ateş yasak / kısıtlı ateş alanı (NFA / RFA)** | Eden/Zeus'ta dikdörtgen ya da elips **harita işareti** oluşturun, adı `TC2_NFA...` (yasak) ya da `TC2_RFA...` (kısıtlı) ile başlasın. NFA içindeki hedefe CAS ve CFF **reddedilir**; RFA'da izin verilir, ağa uyarı düşer. Alanlar HARİTA'da KATMAN açıkken görünür. | Yok |
| **Gece modu** | Gece ya da NVG / termal açıkken terminal otomatik kısılır; CBA `TC2_ui_nightDim` ile kapatılır. | Yok |

## Bilerek ALINMAYANLAR (karmaşıklık)
Hava savunma uyarı/silah kontrol durumu ilanı, sensör veri bağı temasları, telemetre ile otomatik doldurma, PACE otomasyonu, CAS–topçu çakışma önleme / TOT, IR strobu izleme, AAR ekranı, canlı lazer tespiti (doğrulanamaz ve karmaşık). İstenirse tek tek eklenebilir.

## Doktrin dayanağı
JP 3-09.3 (yüklü): lazer kodu 4 hane, LTL, "LASER ON", CAS brifingi; danger close; JP 3-09 / JP 3-09.3: NFA, RFA. ATP 3-09.30: danger close 600 m.
