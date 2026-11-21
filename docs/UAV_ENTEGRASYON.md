# UAV ve kask kamerası — KAMERA sekmesi (yalnızca izleme)

**Karar (kullanıcı):** İHA'ların ve kask kameralarının görüntüsü terminalden ve saha tabletinden **izlenebilir, kontrol edilemez**. Önceki "A/B/C" seçeneklerinden **B (canlı yayın, render-to-texture)** uygulandı; vanilla UAV terminaline BAĞLANILMAZ (`connectTerminalToUAV` kullanılmaz), silah / hedefleme / sürüş yok.

## Nasıl çalışıyor
* Sekme: **KAMERA** (eski UAV yer tutucusunun yerine; 10. sekme). Hem masa başı terminalde hem saha cihazında. Yetki: **Level 2+ ve izleme modunda değil** (er tabletle kamera izleyemez; bilgi güvenirliği).
* **Telsiz:** aktif ACRE2 telsizi ŞART (CBA `TC2_cam_requireRadio` açık, varsayılan). Test için kapatılabilir; telsizsiz kask menzil sınırı da uygulanmaz.
* **Kaynaklar** (sunucu listeler, `camPoll`): (1) aynı taraftaki **İHA'lar** (CBA `TC2_cam_uavShare`, bir İHA'yı gizlemek: `this setVariable ["TC2_camHidden", true, true]`), (2) envanterinde **kask kamerası eşyası** (`TC2_HelmetCam`, CBA'dan değiştirilebilir) olan aynı taraf askerler (oyuncu ya da AI), CBA açıksa izleyenin telsiz menzili içinde.
* **Görüntü:** izleyenin makinesinde yerel kamera nesnesi kaynağa iliştirilir, görüntü bir dokuya yazılır (1024x512), resimde gösterilir. İHA'da kamera yönü pilot kamerasını (gimbal) izler; kaskta askerin kafasına bağlıdır. **Maliyet:** ek render geçişi; yalnızca sekme açık ve kaynak seçiliyken; sekmeden çıkınca / pencere kapanınca kamera yok edilir.
* **Görüntü modu:** NORMAL / NVG / TERMAL düğmeleri yalnızca izleyenin ekranını etkiler (kaynağa komut gitmez).
* **Bilgi paneli:** İHA: tür, irtifa, hız, yön, grid, kamera yönü/eğimi. Kask: çağrı adı, yön, grid, durum.

## Sınırlar (doğrulanmadı, dürüstçe)
* Görüntü için oyun **video ayarlarında PiP (resim içinde resim) açık** olmalıdır; kapalıysa siyah kalır.
* MP'de kaynak, izleyenin makinesine **ağ üzerinden aktarılmıyorsa** (çok uzak) nesne yoktur ya da çevresi yüklenmemiştir: görüntü boş/eksik olabilir ya da "kaynak aktarılmıyor" denir. Bu, oyunun nesne akış (streaming) kuralına bağlıdır ve oyunda denenmedi.
* İHA kamera yönü `getPilotCameraRotation` ile, kask kamerası "head" noktasına iliştirmeyle yapıldı: oyunda doğrulanmadı; yön/konum ince ayar isteyebilir.
* Kamera eşyası bir kask modeli göstermez; yalnızca envanter eşyasıdır.
