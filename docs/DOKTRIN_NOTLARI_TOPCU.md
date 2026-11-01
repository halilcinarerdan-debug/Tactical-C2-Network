# Doktrin notları — dolaylı ateş / topçu (ATP 3-09.30, "Techniques for Observed Fire", 2 Ağustos 2013)

Kaynak: `doktrinler2.txt` (depoda yoktur). Satır numaraları o dosyaya aittir. ATP 3-09.30, FM 6-30'un yerine geçer.
Yanında ATP 3-09.32 (JFIRE: CAS ve gözlemci) ve JP 3-09 (`DOKTRIN_NOTLARI.md`) kullanılır.

## Roller ve zincir (satır ~785-960, 2185-2205)

- **Gözlemci (FO/FIST, JFO)** hedefi bulur, **call for fire (CFF)** gönderir ve atışı düzeltir. CFF bir **istektir, emir değildir**.
- **FDC** (ateş yönetim merkezi) CFF'i alır, **nasıl ve ne ile** ateş edileceğine karar verir ve gözlemciye **MTO** (message to observer) ile bildirir.
  FDC, gözlemcinin istediği mühimmat/eleman büyüklüğünü **değiştirebilir** (saldırı kılavuzu, ROE).
- Dijital CFF birincil; **sesli** CFF dijital kayıpta, "immediate suppression/smoke" gibi acil durumlarda, planlı hedef önceden yüklenmemişse kullanılır.

## CFF: altı eleman, üç aktarım (satır 2228-2237)

Her aktarımdan sonra **ara ver ve geri oku (read back)**. Konum yöntemi ne olursa olsun:

| Aktarım | Elemanlar |
|---------|-----------|
| 1 | **Gözlemci kimliği** + **uyarı emri** (görev türü, FFE eleman büyüklüğü, konum yöntemi) |
| 2 | **Hedef konumu** |
| 3 | **Hedef tanımı** + **angajman yöntemi** + **ateş ve kontrol yöntemi** |

### Uyarı emri (2241-2330)
- **Görev türü:** `ADJUST FIRE` (konum şüpheli), `FIRE FOR EFFECT` (konum kesin), `SUPPRESS` (aktif olmayan, genelde planlı hedef; süre/DURATION ile),
  `IMMEDIATE SUPPRESSION` / `IMMEDIATE SMOKE` (maneviyi ateş altında; **tek aktarım**; konum hemen arkasından).
- **FFE eleman büyüklüğü:** gözlemci isteyebilir, **nihai karar FDC'nin**.
- **Konum yöntemi:** `GRID` (kelime söylenmez), `LASER GRID`, `POLAR`, `LASER POLAR`, `SHIFT (bilinen nokta)`.
  - **Grid:** en az **6 haneli**; kayıt/hassas noktalar için en az 8-10 hane. **Yükseklik (altitude)** gridin hemen arkasından. Gözlemci-hedef yönü ilk CFF'ten **sonra** gönderilir.
  - **Polar:** gözlemci konumu FDC'de bilinir; **yön, mesafe, dikey kayma** (UP/DOWN metre ya da dikey açı mil).
  - **Shift:** bilinen nokta/hedef no; **yön**, sonra **LEFT/RIGHT** (m), **ADD/DROP** (100 m'ye yuvarlanmış), **UP/DOWN** (5 m'ye; ≥35 m anlamlı).
  - Hassas cihazla (lazer vb.) **TLE** (hedef konum hatası) aktarılır.
- **Yön birimi:** milliyem (mil, 6400 = tam daire); FDC derece ve kardinal yön de kabul edebilir. 1° ≈ 17.78 mil.

### Hedef tanımı (2330-2345)
Ne (birlik, ekipman, depo), ne yapıyor (siper kazıyor, toplanma bölgesi), **eleman sayısı**, **koruma derecesi** (açıkta, siperde, üstü kapalı sığınakta),
gerekirse **boyut/biçim** (dikdörtgen: uzunluk × genişlik + attitude; daire: yarıçap; çizgisel: uzunluk + attitude).

### Angajman yöntemi (2348-2430)
- **Düzeltme türü:** **alan** (varsayılan) ya da **hassas** (tek top, noktasal hedef; `DESTRUCTION`).
- **DANGER CLOSE:** hedef (ya da isabet) dost birliklerin **600 m** içindeyse (havan/topçu; 5 inç deniz topu ve TLAM 750 m) angajman yöntemine **eklenmelidir**.
  Risk tahmin mesafeleriyle karıştırılmaz (ATP 3-09.32). Yakınlaşırsa gözlemci DANGER CLOSE bildirir; uzaklaşırsa `CANCEL DANGER CLOSE`.
- **MARK:** gözlemcinin kendini yönlendirmek veya başkalarına hedef göstermek için atış istemesi.
- **Yörünge:** alçak açı (varsayılan), **yüksek açı** (havanlar yalnız yüksek açı atar).
- **Mühimmat:** varsayılan HE + çarpma (quick) tapası; HE, HC, WP, RP (yalnız havan), ILLUM, DPICM, APICM, SMOKE, SCATMINE, hassas mühimmat (EXCALIBUR, APMI, GMLRS — hassas hedefleme gerektirir).
  Tapa: PD, VT, MT, ET, MTSQ, DELAY, MOF (yalnız havan). Adjust'ta/etkide farklıysa önce adjust, sonra etki. `… FOLLOWED BY …`.
- **Hacim:** FFE'de **top başına** mermi (`3 ROUNDS`). **Dağılım (sheaf):** varsayılan 100 m yarıçaplı daire; converged, open, linear, özel (uzunluk/genişlik + attitude).

### Ateş ve kontrol yöntemi (2431-2515)
`FIRE WHEN READY` (varsayılan), **`AT MY COMMAND`** (FDC `… IS READY` der, gözlemci `FIRE` der; yalnız adjust mermileri ve ilk FFE salvosu; `CANCEL AT MY COMMAND` ile biter),
`BY ROUND AT MY COMMAND`, `CANNOT OBSERVE`, **`TIME ON TARGET`** (saat senkron), `TIME TO TARGET` (`HACK`), koordineli/sürekli aydınlatma, `CEASE LOADING`, **`CHECK FIRING`** (acil durdur),
`CONTINUOUS FIRE`, `REPEAT` (ilk CFF'te yok), `SPLASH` isteği (5 sn önce; hava gözlemcisi ve yüksek açıda zorunlu), `DO NOT LOAD`, `DURATION` (bastırma/duman).
**Hata düzeltme:** `CORRECTION` + doğru alt eleman + etkilenen tüm veriler (2516-2533).

## FDC → gözlemci (2534-2627)

- **MTO (4 öğe):** atan birim(ler), CFF'ten **değişiklikler**, **mermi sayısı**, **hedef numarası** (örn. `AF1027`). Ek: PER (≥38 m ise), **Angle T** (≥500 mil ise), PRF kodu (lazer; Ordu 3 hane, Hava Kuvvetleri 4 hane = başına `1`),
  uçuş süresi (hareketli hedef, hava gözlemcisi, yüksek açı, `BY ROUND AT MY COMMAND`), kimlik doğrulama (güvenli olmayan ağda; `challenge/reply` ya da `transmission`).
- **Komutlar:** `SHOT` (adjust'ta her mermiden, FFE'de ilk mermiden sonra; gözlemci `SHOT, OUT`), `SPLASH` (5 sn önce), `ROUNDS COMPLETE` (FFE bitti; gözlemci `ROUNDS COMPLETE, OUT`).
- Örnek sırası (tablo 4-1, 2630-2647): `ADJUST FIRE` → `GRID NK180513 ALTITUDE 345` → `INFANTRY PLATOON IN THE OPEN, ICM IN EFFECT` → MTO `Z, 2 ROUNDS, TARGET AF1027` → `DIRECTION 1680`.

## Atışı düzeltme (bölüm 5, satır 2711-3250)

- **Nişan noktası (adjusting point):** alan hedefte merkeze yakın, iyi tanımlı nokta.
- **Gözlem (spotting) sırası:** yükseklik (AIR/GRAZE/MIXED) → **menzil** (OVER, SHORT, TARGET, RANGE CORRECT, DOUBTFUL, LOST, UNOBSERVED) → **sapma** (LEFT/RIGHT mil, LINE). Alan atışta 5 mile, hassasta 1 mile yuvarlanır.
- **Düzeltme sırası** (gözlemin tersi): **deviation → range → HOB**. Tam iletim sırası: yön → danger close → yörünge → ateş yöntemi → dağılım → mühimmat → tapa → hacim → deviation → range → HOB → hedef tanımı → görev türü/kontrol → splash → repeat. Değişmeyen eleman atlanır.
- **Sapma düzeltmesi:** `sapma (mil) × gözlemci-hedef faktörü (OT factor)` → **10 m'ye yuvarlanır**, gözlemin **tersi yönde** (SOL gözlem ⇒ SAĞA düzeltme). OT faktörü: mesafe >1000 m ise en yakın bin, <1000 m ise en yakın yüz (bin cinsinden). **30 m'den küçük sapma düzeltmesi** ("minör") gönderilmez (rafine/hassas atış hariç).
  Örnek: 4000 m, 45R ⇒ `LEFT 180`.
- **Menzil:** SHORT ⇒ `ADD`, OVER ⇒ `DROP`. Gözlemci agresif olmalı; ilk mermiyi hedefe oturtup FFE'ye hızla geçmeli.
- **HOB (tapa time/VT):** FFE'de hedef 20 m; GRAZE ⇒ `UP 40` (önceden hava patlaması yoksa), önceden varsa `UP 20`. **GRAZE'den ya da DOWN 40'tan büyük düzeltmeyle FFE'ye geçilmez.**
- **Teknikler:** **successive bracketing** (kademeli parantez: 100/200/400/800 m adımlarla böl; 100 m parantez bölününce FFE; FFE mermilerinin 50 m içinde olması matematiksel garanti),
  **hasty bracketing** (ilk düzeltmeyle parantezi cetvel yap, düzeltme + FFE), **one round adjustment** (deneyimli ya da lazer mesafe ölçerli), **creeping fire** (**danger close**: ≤100 m'lik küçük menzil adımlarıyla yaklaştır).
- **FFE ve gözetim (surveillance):** FFE'den sonra gözlemci sonuçları değerlendirir (tablo 5-2, 3220-3250):
  doğru ve yeterli ⇒ `END OF MISSION, <hedef durumu>` (örn. `ROCKET PROPELLED GRENADE DESTROYED`); yeniden çizim istenirse `RECORD AS TARGET`;
  yanlış ama yeterli ⇒ rafine düzeltme + `END OF MISSION`; yanlış ve yetersiz ⇒ düzeltme + `REPEAT` ya da `ADJUST FIRE`.
- Kayıp mermi (`LOST`): veri kontrolü, WP/duman/200 m HE hava patlaması iste, `REPEAT`, görevi bitirip yenisini başlat ya da cesur kayma (dostlar yakınsa dikkatli).

## Tasarıma etkisi (öneriler)

- **FDC'yi otomatik (sanal) yapmak** doktrindeki MTO/SHOT/SPLASH/ROUNDS COMPLETE akışını birebir üretir; gözlemci düzeltmeleri yine **kendisi** gözleyip gönderir (otomatik düzeltme yok).
- **Sunucuda uygulanacak kurallar:** danger close (600 m, dost konumlarından), görev türüne göre zorunlu alanlar, FFE'nin GRAZE/HOB kuralları (tapa time seçilirse), ilk CFF'te REPEAT yasağı,
  minör sapma (<30 m) uyarısı, mermi sayısı sınırı, FDC'nin kararı değiştirebilmesi (MTO'daki "değişiklikler").
- **Mil ↔ derece:** arayüz derece ya da mil kabul eder; sunucu dahili olarak metre/yön hesaplar.
