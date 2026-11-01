/*
    Fonksiyon: TC2_fnc_opordTemplate
    Çalışma yeri: Her makine (saf fonksiyon)

    Boş OPORD şablonu: BEŞ PARAGRAF düzeni (1 Situation, 2 Mission, 3 Execution, 4 Sustainment, 5 Command and Signal) + görev organizasyonu +
    ateş desteği eki. Her bölümün varsayılan yetki seviyesi vardır (düşman bilgisi, ateş planı, manevra planı, CCIR, haberleşme gibi hassas
    bölümler daha yüksek). İçerik, yazarın doldurması için kısa ipuçlarıdır.

    DOKTRİN DAYANAĞI (JP 3-0, 17 Ocak 2017, Değişiklik 1; `docs/DOKTRIN_NOTLARI_OPORD.md`):
      - Emir/plan, komutanın katılımını isteyen öğeleri içerir: görev ifadesi (kim, ne, ne zaman, nerede, neden), komutan niyeti
        (amaç, istenen son durum ve ilişkili riskler), CCIR'ler (PIR + FFIR) ve harekât konsepti (CONOPS).
      - CONOPS emrin 3. paragrafındadır (Execution); olası dalları (branch) ve devamları (sequel) içerir; ateş konsepti, istihbarat
        operasyonları konsepti ve lojistik genel bakışın dayanağıdır.
      - CCIR'ler yalnızca komutana aittir, liste kısa tutulur ve her safha geçişinde gözden geçirilir -> Level 3.
      - ROE, kısıtlar (constraints) ve sınırlamalar (restraints) emirle verilen harekât sınırlarıdır; sonlandırma ölçütleri belirtilir.
      - Safhalama (notional): şekillendirme, caydırma, inisiyatifi ele geçirme, hâkimiyet, istikrar, sivil otoriteyi destekleme.
    Alt paragraf başlıkları (1.a..1.e, 3.c..3.f, 5.a..5.c) ABD Ordusu beş paragraf biçimindendir (FM 6-0 / ATP 5-0.1). JP 5-0 yüklenirse
    alt başlıklar doğrulanır. Ateş paragrafı için JP 3-09.3 (görev, amaç, yöntem, etki = TPME) kullanıldı.

    Parametreler: yok
    Dönüş: bölümler <ARRAY>  [[anahtar, başlık, seviye, metin]]
*/

[
    ["TASKORG", "GÖREV ORGANİZASYONU (Task Organization)", 1, "[Birliklerin bu görev için nasıl düzenlendiği: alt birimler, atanan/bağlanan unsurlar, çağrı adları.]"],
    ["1A", "1.a OPERASYON ALANI (Area of Operations)", 1, "[Arazi (kritik arazi, yaklaşma yolları, engeller) ve hava/aydınlık durumu.]"],
    ["1B", "1.b DÜŞMAN KUVVETLERİ (Enemy Forces)", 2, "[Bileşim, yerleşim, güç, yetenekler; en olası ve en tehlikeli hareket tarzı.]"],
    ["1C", "1.c DOST KUVVETLER (Friendly Forces)", 1, "[Üst karargahın görevi ve niyeti, yanlardaki birlikler, destek veren unsurlar.]"],
    ["1D", "1.d EKLEME VE AYIRMALAR (Attachments and Detachments)", 1, "[Göreve eklenen ve ayrılan unsurlar.]"],
    ["1E", "1.e VARSAYIMLAR (Assumptions)", 2, "[Planlama varsayımları.]"],
    ["2", "2. GÖREV (Mission)", 1, "[Görev ifadesi: kim, ne, ne zaman, nerede ve neden. Bir cümle ya da kısa paragraf; temel görev ve amacı açıkça söyler.]"],
    ["3A", "3.a KOMUTAN NİYETİ (Commander's Intent)", 1, "[Komutanın net ve kısa ifadesi: gücün ne yapması gerektiği ve görevi başarmak için oluşturması gereken koşullar. AMAÇ, İSTENEN SON DURUM ve İLİŞKİLİ RİSKLER.]"],
    ["3B", "3.b HAREKÂT KONSEPTİ (Concept of Operations)", 1, "[Eylemlerin nasıl bütünleştirileceği, senkronize edileceği ve safhalandırılacağı. Safhalar (örn. şekillendirme, caydırma, inisiyatifi ele geçirme, hâkimiyet, istikrar, sivil otoriteyi destekleme: göreve uygun olanlar). Olası DALLAR (branches) ve DEVAMLAR (sequels).]"],
    ["3C", "3.c MANEVRA PLANI (Scheme of Movement and Maneuver)", 2, "[Hareket güzergâhları, atılış hattı, ana ve yardımcı kuvvetler.]"],
    ["3D", "3.d ATEŞ KONSEPTİ (Concept of Fires)", 2, "[Ateş destek görevleri: görev, amaç, yöntem, etki (TPME). Yakın hava desteği (CAS), topçu/havan, öncelikli hedefler.]"],
    ["3E", "3.e MANEVRA BİRLİKLERİNE GÖREVLER (Tasks to Maneuver Units)", 2, "[Her manevra birliği için görev ve amaç.]"],
    ["3F", "3.f DİĞER BİRLİKLERE GÖREVLER (Tasks to Other Units)", 2, "[Destek, istihbarat, mühendis, ... birliklerine görevler.]"],
    ["3G", "3.g KOORDİNASYON TALİMATLARI (Coordinating Instructions)", 1, "[Zaman çizelgesi. ANGAJMAN KURALLARI (ROE), KISITLAR (constraints: yapılması zorunlu) ve SINIRLAMALAR (restraints: yapılması yasak). Sonlandırma ölçütleri. Dost ateşi önlemleri.]"],
    ["CCIR", "3.g.1 KRİTİK BİLGİ İHTİYAÇLARI (CCIR)", 3, "[Komutanın karar için kritik saydığı bilgi. Kısa liste. PIR (düşman ve ortam hakkında öncelikli istihbarat ihtiyaçları) ve FFIR (dost kuvvet bilgi ihtiyaçları). Her safha geçişinde gözden geçirilir.]"],
    ["3H", "3.h İSTİHBARAT OPERASYONLARI KONSEPTİ (Concept of Intelligence Operations)", 2, "[Bilgi toplama planı: gözetleme/keşif unsurları, raporlama ve istihbarat yolu.]"],
    ["4", "4. İDAME (Sustainment)", 1, "[İkmal, bakım, sıhhiye/tahliye, personel. Lojistik genel bakış (ulaştırma, depolama).]"],
    ["5A", "5.a KOMUTA (Command)", 1, "[Komutan ve ikinci komutanın yeri, komuta devri sırası.]"],
    ["5B", "5.b KONTROL (Control)", 2, "[Komuta noktaları, kontrol hatları ve ölçüleri.]"],
    ["5C", "5.c HABERLEŞME (Signal)", 3, "[Telsiz ağları ve kanalları, çağrı adları, lazer kodları, şifre/parola.]"],
    ["FIRES", "EK D: ATEŞ DESTEĞİ (Fire Support Annex)", 2, "[Ateş destek planı: JTAC / gözlemci / FDC çağrı adları, onay makamı, ateş destek koordinasyon önlemleri, hedef listesi.]"]
]
