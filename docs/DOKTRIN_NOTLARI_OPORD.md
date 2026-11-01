# Doktrin notları — operasyon emri (OPORD) (JP 3-0, 17 Ocak 2017, Değişiklik 1)

Kaynak: `doktrinler3.txt` (depoda yoktur). Satır numaraları o dosyaya aittir.

## JP 3-0 emir/plan hakkında ne söylüyor

JP 3-0 harekât doktrininin ana belgesidir; emrin **paragraf paragraf biçimini vermez** (o, JP 5-0 *Joint Planning*'dedir; bkz. satır 1870, 1905).
Verdikleri, emrin **içeriğini** belirler:

| Öğe | JP 3-0'ın söylediği | OPORD şablonundaki karşılığı |
|-----|---------------------|-------------------------------|
| **Görev ifadesi** (1789-1798) | Bir cümle ya da kısa paragraf; temel görev ve amaç; **kim, ne, ne zaman, nerede, neden**. Komutan onaylar, astlarca anlaşılmalı. | `2. GÖREV` (Seviye 1) |
| **Komutan niyeti** (1824-1835) | Gücün ne yapması gerektiğinin ve görevi başarmak için oluşturması gereken koşulların net ve kısa ifadesi. **Amaç, istenen son durum ve ilişkili riskler** içerir. Astlara en geniş hareket serbestisini verir. | `3.a KOMUTAN NİYETİ` (Seviye 1) |
| **CCIR** (1836-1839, 2577-2600) | Karar için kritik bilgi. **PIR** (düşman/ortam, J-2) ve **FFIR** (dost kuvvet, J-5) oluşur. **Yalnızca komutana aittir**, liste **kısa** tutulur, **her safha geçişinde** gözden geçirilir. | `3.g.1 CCIR` (**Seviye 3**) |
| **CONOPS** (1840-1850) | Emrin **3. paragrafında (Execution)**. Bileşenlerin eylemlerinin nasıl bütünleştirileceğini, senkronize edileceğini ve safhalandırılacağını anlatır; olası **dallar (branches) ve devamlar (sequels)** içerir. **Ateş konsepti, istihbarat operasyonları konsepti ve lojistik genel bakış**ın dayanağıdır. | `3.b HAREKÂT KONSEPTİ`, `3.d ATEŞ KONSEPTİ`, `3.h İSTİHBARAT OP. KONSEPTİ`, `4. İDAME` |
| **ROE, kısıtlar, sınırlamalar** (1263) | Komutanlar **angajman kuralları (ROE), kısıtlar (constraints) ve sınırlamalar (restraints)** gibi harekât sınırları koyar; bunlar emirlere girer. | `3.g KOORDİNASYON TALİMATLARI` |
| **Sonlandırma ölçütleri** (1275-1284) | Bir harekâtın bitebilmesi için sağlanması gereken koşullar. | `3.g` |
| **Uyarı emri** (1631) | Astların planlamaya zaman bulması için en erken fırsatta verilir. | (ileride: ayrı belge türü) |
| **Safhalama** (655-690) | Altı genel faaliyet grubu: şekillendirme, caydırma, inisiyatifi ele geçirme, hâkimiyet, istikrar, sivil otoriteyi destekleme. Gerçek safhalar göreve göre kısaltılır/genişletilir/atlanır. | `3.b` ipucu |
| **Komuta ilişkisi/ateş desteği** | Ateş planlaması için JP 3-09, JP 3-09.3, JP 3-60'a atıf. | `EK D: ATEŞ DESTEĞİ` |

## Paragraf düzeni

JP 3-0 yalnızca **"paragraph 3 (Execution)"** ifadesiyle beş paragraf düzenini doğrular (1840). Şablon bu nedenle **ABD beş paragraf düzenini**
kullanır: **1 Situation, 2 Mission, 3 Execution, 4 Sustainment, 5 Command and Signal** (+ görev organizasyonu ve ekler).
Alt paragraf başlıkları (1.a-1.e, 3.c-3.f, 5.a-5.c) FM 6-0 / ATP 5-0.1'den, JP 5-0 ve bu dokümanlarda **doğrulanmamıştır**.
Doğrulama için JP 5-0 (ya da ATP 5-0.1) yüklenirse şablon ona göre düzeltilir.

## Yetki seviyeleri (tasarım)

JP 3-0'daki "CCIR yalnızca komutana aittir" ilkesi ve hassas planlama (JP 3-0, 1631-1635: sınırlı erişimli planlama) ışığında:

| Seviye | Kim | Gördüğü |
|--------|-----|---------|
| **1** | herkes | görev organizasyonu, alan, dost kuvvet, görev, niyet, konsept, koordinasyon talimatları, idame, komuta |
| **2** | grup lideri, JTAC / gözlemci / FDC, ya da rütbe ≥ CBA eşiği (varsayılan ÇAVUŞ) | + düşman, varsayımlar, manevra, ateş konsepti, birliklere görevler, istihbarat konsepti, kontrol, ateş eki |
| **3** | rütbe ≥ CBA eşiği (varsayılan TEĞMEN) ya da `TC2_level = 3` | + **CCIR, haberleşme (frekans, çağrı adı, lazer kodu)**; OPORD'u **düzenleyebilir** |
