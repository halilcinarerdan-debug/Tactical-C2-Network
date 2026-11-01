# Doktrin notları — WARNO, SALUTE, SITREP, LACE (Aşama 6b)

## Kaynaklar

* **ATP 3-21.8** *Infantry Rifle Platoon and Squad* (`doktrinler_5.txt`): LACE, SALUTE kullanımı, durum renkleri, WARNORD içeriği. **LACE'in doktrin dayanağı budur.**
* **JP 1-02** (DoD Dictionary): SALUTE açılımı, SITREP / spot report / warning order tanımları. Sözlüktür, rapor formatı vermez.

| Terim | Dayanak | Sistemde kullanımı |
|-------|---------|--------------------|
| **LACE** | ATP 3-21.8 **8-13**: "liquid, ammunition, casualties, and equipment (LACE)" durumunun alt birliklerin raporuyla bilinmesi; kıtlık şimdi mi, ileride mi, görevi etkiler mi diye değerlendirilir. ATP 3-21.8 **7-116/7-117**: hedefte konsolidasyondan sonra element liderleri LACE raporunu devriye lideri ve yardımcısına verir. | **RAPOR** sekmesi, tür LACE: Liquid, Ammunition, Casualties, Equipment için renk + not. |
| **Durum renkleri** | ATP 3-21.8 **2-80** (FM 1-02.2): yeşil tam operasyonel (**yüzde 85+**), amber büyük ölçüde (**70-84**), kırmızı sınırlı (**50-69**), siyah operasyonel değil (**50 altı**), bilinmiyor. | Liderin beyan listesi (5 seçenek) ve sistem hesabı (`rptLaceStatus`) bu eşikleri kullanır. |
| **SALUTE** | ATP 3-21.8 **1-26**: manga lideri takım lideri'ne SALUTE spot raporu verir; **7-159**: güvenlik elemanı düşman yaklaşınca SALUTE ile bildirir. JP 1-02: size, activity, location, unit, time, equipment. | **RAPOR** sekmesi, tür SALUTE (6 alan). |
| **Durum raporu (SITREP)** | ATP 3-21.8 **1-26**: manga lideri takım lideri'ne **konum ve ilerleme, düşman durumu, düşman KIA, güvenlik duruşu**; mühimmat/kayıp/teçhizat durumunu takım astsubayı'na bildirir. **4-118**: yeniden düzenlemede kritik eksiklerin tespiti ve **ikmal talebi**. JP 1-02: "raporlayan birliğin bölgesindeki durum". | **RAPOR** sekmesi, tür SITREP: faaliyet/ilerleme, düşman durumu, düşman KIA, güvenlik duruşu, ikmal talebi, notlar (+ otomatik konum). Mühimmat/kayıp/teçhizat için LACE kullanılır. |
| **WARNORD (WARNO)** | JP 1-02 (JP 5-0) tanımı. ATP 3-21.8 **2-20..2-22**: beş paragraf biçimini izler, mümkün olan en erken verilir; takım WARNORD'u şunları içerir: operasyon türü, genel yer, ilk zaman çizelgesi, başlatılacak hareketler, ortak planlama oturumları, planlama ve hazırlık talimatları (PCC, PCI, prova), ilk bilgi ihtiyaçları (CCIR: PIR, FFIR), ilk bilgi toplama görevleri. | **OPORD** sekmesi, belge türü **WARNO**; 11 bölümlü şablon bu listeden (bölüm 10, CCIR, Level 3). |
| **spot report** | JP 1-02 (JP 3-09.3): olay/durum hakkında en hızlı yolla kısa rapor. | SALUTE bu amaçla kullanılır. |

**Sınırlar (dürüstçe):**
* ATP 3-21.8 şekil 2-3 (WARNORD biçim örneği) elimizdeki metinde bir **görsel**, okunamadı; bölüm başlıkları metindeki listeden türetildi.
* ATP 3-21.8 LACE için **sabit bir form** vermiyor; LACE alanlarını ve renk ölçeğini veriyor. Her alanın (örn. Liquid için su/yakıt) yüzdesi oyunda sayısal ölçülemediği için **beyan** niteliğindedir.
* Casualties ve Equipment'ın **sayısal** kısmı (kuvvet oranı, araç hasarı) sistemce hesaplanır; hesap yöntemi (yaralı/etkisiz kuralı, araç hasarı = 100 - hasar yüzde) tasarım kararıdır.
* LACE'in "kim kime" zinciri doktrinde takım/manga düzeyindedir; sistemde LACE ağdaki tüm Level 2+ oturumlara görünür (COP).

## LACE'in sistemde çalışışı (bilgi güvenirliği)

* **Sistemin DOĞRULADIĞI sayılar** (lider değiştiremez, sunucu oyundan okur): mevcut personel, ilk büyüklük (grupta görülen en yüksek üye sayısı),
  yaralı/etkisiz (ACE bilinçsiz, vanilla INCAPACITATED ya da hasar > 0,3), araç hasarı yüzdesi.
* **Liderin BEYAN ettiği** durumlar: Liquid, Ammunition, Casualties, Equipment için GREEN / AMBER / RED / BLACK / UNKNOWN + kısa not (45 dk içindeki son rapor geçerli).
* Haritadaki renk, **en kötü** durumdur (sistem verisi ile beyanın en kötüsü; UNKNOWN hesaba katılmaz). Lider yanlış "yeşil" yazsa bile sayılar ağırlaşırsa renk bozulur.
* Kuvvet oranı = (mevcut - yaralı/etkisiz) / ilk büyüklük; eşikler 85 / 70 / 50. Araç tek başına en çok KIRMIZI yapar.
* LACE yalnızca **Level 2+ ve izleme modunda olmayan** oturumlarda görünür.

## SALUTE doğrulama (S2 / CO)

SALUTE, sahadaki lider tarafından gönderilir fakat **doğrulanana kadar** haritada **soru işaretli simge** olarak kalır (düşman işareti DEĞİL).
S2 ya da CO "doğrula" der ⇒ rapor konumunda **DÜŞMAN PİYADE işareti** oluşur, MicroDAGR'a gider. Amaç: tek bir erin yanlış raporuyla ortak resmin bozulmaması.
Bu bir **tasarım kararıdır**, JP 1-02'den gelmez.

## Yetki modeli (kullanıcı kararı)

| Kimlik | Seviye | Yetki |
|--------|--------|-------|
| Kırmızı kart | Level 1 | Kendi görevlerini (Level 1 bölümleri) okur; rapor ve LACE göremez/yazamaz |
| Mavi kart | Level 2 | Gizli (Level 3) belgeleri göremez; 9-Line, topçu CFF, rapor yazar |
| Siyah/Altın kart | Level 3 | Her şeyi görür, OPORD/WARNO düzenler |
| CO (Bölük Komutanı) | Level 3 | masa başı |
| S2 (İstihbarat) | Level 3 | masa başı; SALUTE doğrular |
| S4 (Lojistik) | Level 2 ya da 3 | CBA `TC2_s4_level` |
| Saha tableti, grup/takım lideri, JTAC, gözlemci | FIELD (en çok Level 2) | tam kullanım: rapor, işaret, CAS, CFF |
| Saha tableti, er | VIEW | yalnızca harita + işaretler (+ Level 1 belgeler); yazamaz, LACE göremez |
| Hava aracı mürettebatı | — | tablet şartından muaf |

Tablet kuralı: hava aracı (uçak/helikopter) mürettebatı dışında **herkes** terminale bilgi göndermek ve almak için envanterinde `TC2_Tablet` taşımalıdır (CBA ayarı boşsa şart yok).
