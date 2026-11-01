# Doktrin notları — WARNO, SALUTE, SITREP, LACE (Aşama 6b)

Kaynak: `doktrinler4.txt` = **JP 1-02 (DoD Dictionary)**. JP 1-02 bir **sözlüktür**: terimleri tanımlar, rapor FORMATLARINI vermez.

## JP 1-02'de bulunanlar

| Terim | JP 1-02'deki durum | Sistemde kullanımı |
|-------|--------------------|--------------------|
| **warning order (WARNORD / WARNO)** | Var (JP 5-0): "bir emrin ya da eylemin habercisi ön bildirim"; 3. anlam: durumu anlatan, kuvvet ve kaynak ayıran, komuta ilişkilerini kuran, ilk planlama rehberini veren ve alt birlik planlamasını başlatan planlama direktifi. | **OPORD** sekmesinde belge türü **WARNO**. Şablon, bu tanımın saydığı öğeleri taşır (durum, kuvvet/kaynak, komuta ilişkisi, planlama rehberi, zaman çizelgesi). OPORD ile AYNI yetki seviyesi ve sunucuda süzme altyapısı. |
| **situation report (SITREP)** | Var (JP 3-50): "bir raporlayan birliğin ya da oluşumun bölgesindeki durumu veren rapor". | **RAPOR** sekmesi, tür SITREP. Alanlar: konum, faaliyet, düşman, personel, lojistik, niyet, notlar. Alan listesi doktrin değil, tanımın kapsamından türetilmiş **tasarım kararıdır**. |
| **SALUTE** | Yalnızca **kısaltma listesinde**: size, activity, location, unit, time, equipment. Format ve kullanım kuralı yok. | **RAPOR** sekmesi, tür SALUTE; 6 alan kısaltmanın açılımıdır. |
| **spot report (SPOTREP)** | Var (JP 3-09.3): olay/durum hakkında en hızlı yolla iletilen kısa rapor. | SALUTE bu amaçla kullanılır; ayrıca doğrulama (aşağıda). |
| **intelligence report (INTREP)** | Var (JP 2-01). | Doğrulanmış SALUTE → istihbarat işareti. |
| **LACE** | **YOK.** Sözlükte ne tanım ne kısaltma var. | Aşağıya bakın. |

## LACE hakkında dürüst durum

**LACE JP 1-02'de (ve elimizdeki JP 3-09.3, JP 3-09, ATP 3-09.30, JP 3-0'da) bulunmuyor.** Genel bilgi olarak LACE, küçük birlik komutanlarının
komutanına verdiği hızlı kaynak/durum özetidir: **L**iquids (su, yakıt), **A**mmunition (mühimmat), **C**asualties (kayıp), **E**quipment (teçhizat).
Uygulamadaki yeşil / amber / kırmızı / siyah durum kodu ve yüzde eşikleri (yaklaşık %80 / %60 / %40) **birliğin SOP'una bağlıdır**; sistemde
bu eşikler **ayarlanabilir ŞEKİLDE DEĞİL, koda gömülü tipik değerlerdir (`rptLaceStatus`)** ve doktrinle DOĞRULANMAMIŞTIR.
Kaynak olarak ATP 3-21.8 (piyade müfrezesi/takımı) ya da FM 7-8 / ilgili SOP verilirse alan ve eşikler doktrine göre düzeltilecektir.

## LACE'in sistemde çalışışı (bilgi güvenirliği)

* **Sistemin DOĞRULADIĞI sayılar** (lider değiştiremez, sunucu oyundan okur): mevcut personel, ilk büyüklük (grupta görülen en yüksek üye sayısı),
  yaralı/etkisiz (ACE bilinçsiz, vanilla INCAPACITATED ya da hasar > 0,3), araç hasarı yüzdesi.
* **Liderin BEYAN ettiği** durumlar: Liquids, Ammunition, Casualties, Equipment için GREEN / AMBER / RED / BLACK + kısa not (45 dk içindeki son rapor geçerli).
* Haritadaki renk, **en kötü** durumdur (sistem verisi ile beyanın en kötüsü). Casualties/Equipment için lider yanlış "yeşil" yazsa bile sayılar ağırlaşırsa renk bozulur.
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
