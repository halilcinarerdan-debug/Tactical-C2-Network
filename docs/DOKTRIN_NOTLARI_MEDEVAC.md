# Doktrin notları — 9-Line MEDEVAC (CASEVAC)

## Yüklenen dokümanlardaki dayanak
* **ATP 3-21.8, 8-44 … 8-46:** Taktik tahliye aşamasında yaralılar MTF'lere taşınır. **MEDEVAC** = özel işaretli, tıbbi personelle donatılmış (kara/hava) ambulanslar; **CASEVAC** = tıbbi personeli/donanımı olmayan, görevlendirilmiş ya da fırsat platformlarla taşıma. Yaralı noktası → takım/bölük yaralı toplama noktası (CCP) arası taşıma bu bağlamda CASEVAC sayılır. **"9-line MEDEVAC isteği (GTA 08-01-004), hava ambulansı istemenin standart yöntemidir."**
* ATP 3-21.8 8-45 uyarısı: CASEVAC platformunda yolculukta uygun bakım sağlanamayabilir; ölüm/sakatlık riski artabilir. Sistemde bu yüzden talep doğrudan **helikopter mürettebatına** gider, hasta kayıtları sayılarla verilir.
* ATP 3-21.8 2-80/8-…: hazırlık, yaralı toplama, MEDEVAC prova edilir (prova listesinde "9-line medical evacuation" geçer).

## Yüklenen dokümanlarda OLMAYAN
**Dokuz satırın içeriği** (GTA 08-01-004) yüklenen hiçbir dokümanda yoktur. Kullanılan satırlar genel bilgidir (savaş zamanı sürümü) ve **doğrulanmamıştır**:

| Satır | İçerik | Sistemdeki alan |
|-------|--------|-----------------|
| 1 | Alım yeri (grid) | kendi konumum ya da haritadaki bir işaret |
| 2 | Telsiz frekansı, çağrı adı | otomatik: çağrı adı + ağ (tip, kanal); isteğe bağlı ek not |
| 3 | Hasta sayısı, öncelik: A acil, B acil-cerrahi, C öncelikli, D rutin, E kolaylık | beş sayı (0-9) |
| 4 | Özel ekipman: A yok, B vinç, C kurtarma ekipmanı, D ventilatör | seçim |
| 5 | Hasta tipi: L sedyeli, A yürüyebilen/oturan | iki sayı (0-9) |
| 6 | Güvenlik (savaş zamanı): N düşman yok, P olası, E düşman var, X silahlı eskort | seçim |
| 7 | İşaretleme: A panel, B piroteknik, C duman, D yok, E diğer | seçim |
| 8 | Uyruk/durum: A ABD asker, B ABD sivil, C ABD dışı asker, D ABD dışı sivil, E EPW | seçim (dost/dost dışı olarak uyarlandı) |
| 9 | CBRN (savaş zamanı): N, B, C | seçim |

Tutarlılık kuralı (satır 3 toplamı = satır 5 toplamı) ve en az 1 hasta şartı tasarım kararıdır. Barış zamanı sürümü (satır 6 yara/hastalık sayısı, satır 9 arazi tarifi) uygulanmadı.
**Doğrulama için:** GTA 08-01-004 (MEDEVAC Request Card), ATP 4-02.2 (Medical Evacuation) ya da FM 4-02 yüklenirse satırlar doktrine göre düzeltilecek.

## Sistem tasarımı
* **Kim talep eder:** Level 2+ (Mavi kart, grup lideri tabletle, CO/S2/S4); izleme modundaki er ve Level 1 talep edemez.
* **Kime gider:** Aynı telsiz tipi + kanalda, menzil içindeki **helikopter** mürettebatı (sabit kanat dahil değil). Simüle mürettebat (`debugCasPilot`, platform "RW") 4 sn sonra kabul eder.
* **Mürettebat:** bildirim + bip; ACE self menüsünde **TC2 MEDEVAC → #id OKU / #id KABUL**. Kabul eden ilk mürettebat alır; diğerlerine "başkası aldı" gider. Tahmini varış = alım yerine düz mesafe / 55 m/s (bilgi amaçlı, tasarım kararı).
* **Talep sahibi:** MEDEVAC sekmesinde talebin durumu (AÇIK / KABUL + ETA / İPTAL), iptal düğmesi. Aynı ağdaki Level 2+ terminaller talepleri görür.
* Her gönderenin tek etkin talebi vardır (yenisi eskisini iptal eder). Tüm işlemler sunucuda doğrulanır ve RPT'ye `[TC2][MEDEVAC]` yazılır.
* Geri okuma (readback) zorunlu DEĞİL (CAS'tan farkı): doktrinde MEDEVAC için tanımlı değil; yüklenen kaynakta yok.
