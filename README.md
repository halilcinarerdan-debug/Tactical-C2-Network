# Tactical C2 Network (TC2) — ACE3 + ACRE2 komuta-kontrol ağı

Oyuncuların "M tuşuyla her şeyi gördüğü" bir sistem değil; **OPSEC** kurallarının işlediği, yetki seviyeli, fiziksel bir
karargah terminali (laptop) üzerinden **9-Line CAS**, **istihbarat** ve **lojistik** akışı. Doktrin: JP 3-09.3 ve JP 3-09
(özet: [`docs/DOKTRIN_NOTLARI.md`](docs/DOKTRIN_NOTLARI.md)).

Tek mod (`@TC2`), tek PBO (`tc2_main.pbo`). Gerektirir: **CBA_A3**, **ACE3**. **ACRE2** Aşama 3'ten itibaren eklenecek.

## Yol haritası

| # | Aşama | Durum |
|---|-------|-------|
| 1 | Fiziksel terminal + OPSEC (kimlik kartıyla erişim) | ✅ hazır (test bekliyor) |
| 2 | Terminal arayüzü (RscDisplay, yeşil/siyah, sekmeli) | ⏳ |
| 3 | ACRE2 sinyal entegrasyonu (menzil/telsiz kontrolü) | ⏳ |
| 4 | Ortak harekat resmi (COP) + harita işaretleme | ⏳ |
| 5 | Dijital 9-Line CAS talebi (Type 1/2/3, BOT/BOC) | ⏳ |
| 6 | Sınıflandırılmış belgeler (OPORD/INTSUM) + lojistik, Level 1/2/3 | ⏳ |

## Depo yapısı

Depo kökü, P: sürücüsünde `P:\z\tc2` olacak şekilde konumlandırılır (aşağıya bak).

```
mod.cpp                                  @TC2 kök klasörüne kopyalanır
addons/main/                             -> tc2_main.pbo   (prefix: z\tc2\addons\main)
    $PBOPREFIX$                          Mikero bu dosyadan prefix'i okur
    config.cpp                           CfgPatches, TC2_Terminal_F, CfgFunctions, CfgRemoteExec, CBA XEH
    XEH_preInit.sqf                      tüm makineler: CBA ayarları
    XEH_postInit.sqf                     yalnızca istemci: ACE eylemleri
    core/                                ortak yardımcılar
        fn_notify.sqf                    ACE tarzı bildirim (hata/başarı/bilgi)
        fn_debugInfo.sqf                 teşhis: rol, kart sınıfı, envanter, yakın terminaller (panoya kopyalar)
        fn_debugCard.sqf                 TEST: kartı ver / al
    terminal/                            1. aşama
        fn_terminalInitSettings.sqf      CBA ayarları
        fn_terminalPostInit.sqf          istemci kurulumu
        fn_terminalInitActions.sqf       ACE eylemi (TC2_Terminal_F sınıfına)
        fn_terminalCreate.sqf            [SUNUCU] çalışma zamanında terminal yarat
        fn_terminalGetId.sqf             terminal kimliği
        fn_terminalOpen.sqf              [İSTEMCİ] onay sonrası: Aşama 2'de arayüzü açacak yer
        fn_accessGetCardClasses.sqf      kart ayarını çöz (Item_ ön eki toleransı)
        fn_accessHasCard.sqf             birimde kart var mı (saf fonksiyon)
        fn_accessCheck.sqf               [SUNUCU] erişim kararı (saf fonksiyon)
        fn_accessReasonText.sqf          neden kodu -> Türkçe mesaj
        fn_accessRequest.sqf             [İSTEMCİ] talebi başlat (ön kontrol + ilerleme çubuğu)
        fn_accessServerHandle.sqf        [SUNUCU] göndereni doğrula, karar ver, kayıt tut, yanıtla
        fn_accessResult.sqf              [İSTEMCİ] sunucu kararını uygula
docs/
    DOKTRIN_NOTLARI.md                   doktrinden çıkan kurallar (9-Line, Type 1/2/3, BOT/BOC, roller)
    TEST_ASAMA1.md                       tek başına test: editör, hosted MP, yerel dedicated
```

## Mikero ile derleme

1. Mikero araçlarını (**pboProject**, MakePbo, DePbo) ve P: sürücüsünü kur.
2. Depoyu `P:\z\tc2` yoluna getir. Ya doğrudan oraya klonla ya da yönetici komut isteminde:
   ```bat
   mklink /J "P:\z\tc2" "C:\yol\Tactical-C2-Network"
   ```
   (`P:\z` klasörü önceden var olmalı.) Sonuçta `P:\z\tc2\addons\main\config.cpp` bulunmalı.
3. pboProject'te kaynak klasör: `P:\z\tc2\addons\main`, çıktı klasörü: `...\@TC2\addons`.
   Prefix, klasördeki `$PBOPREFIX$` dosyasından okunur (`z\tc2\addons\main`).
4. `mod.cpp` dosyasını `...\@TC2\` köküne kopyala.
5. **Vanilla taban sınıf:** `TC2_Terminal_F`, vanilla `Land_Laptop_unfolded_F` sınıfından türer (`A3_Structures_F_Items_Electronics` yaması).
   pboProject bu taban sınıfı çözebilmek için vanilla Arma 3 verisine ihtiyaç duyar: Arma 3 Tools → **Mount & Populate P: drive**
   (`P:\a3\structures_f\items\electronics\config.cpp` var olmalı). Yoksa "undefined base class" hatası alırsın.
6. `requiredAddons` (cba_main, ace_main, ace_common, ace_interact_menu) bulunamadı uyarısı için `a3ace3ex` deposundaki README'deki notla aynı çözüm geçerlidir.
7. İmza: dedicated sunucuda `verifySignatures` açıksa PBO'yu `.biprivatekey` ile imzala, `.bikey`'i sunucunun `keys/` klasörüne koy.
   **`.biprivatekey` dosyasını asla depoya koyma** (`.gitignore` engeller).

Sonuç: `@TC2\addons\tc2_main.pbo` (+ varsa `.bisign`) ve `@TC2\mod.cpp`.

## Kurulum / başlatma

```
-mod=@CBA_A3;@ace;@TC2
```

**Sunucu ve tüm oyuncular aynı sürümü yüklemelidir.** Erişim kararı sunucuda verildiği için sunucuda `@TC2` yoksa terminal
"SUNUCU YANIT VERMEDİ" zaman aşımı mesajı verir. `@TC2`, CBA ve ACE'den sonra gelmelidir. `@TAC` (a3ace3ex) ile birlikte kullanılabilir.

## Aşama 1 – Fiziksel terminal + OPSEC

### Nasıl çalışır

1. **Terminal objesi:** `TC2_Terminal_F` ("TC2 Command Terminal"), vanilla açık laptop modelinin kendi sınıfımız.
   Eden'de **Objects (F6) → Tactical C2 Network → Terminals**; Zeus'ta aynı kategori; script ile `TC2_fnc_terminalCreate`.
2. **Etkileşim:** ACE ana etkileşim menüsünde (Sol Windows) terminale bakınca **Terminale Giriş (Kimlik Kartı)** eylemi görünür.
3. **Kimlik kartı:** envanterde (üniforma/yelek/çanta) ya da atanmış eşyalarda kart yoksa anında
   *"ERİŞİM REDDEDİLDİ: Kimlik kartı (CAC) bulunamadı."* hatası verilir. Kart varsa 2 sn'lik *"Kimlik doğrulanıyor..."* çubuğu çalışır.
4. **Sunucu kararı:** çubuk bitince talep sunucuya gider; sunucu kartı, mesafeyi (≤ 5 m), canlılığı ve bilinci **kendi verisiyle** yeniden denetler.
   Onayda *"ERİŞİM ONAYLANDI"* gösterilir. (Aşama 2'de burada terminal arayüzü açılacak.)

### Kimlik kartı sınıfı hakkında önemli not (`Item_CAC_Card`)

Arma'da `Item_Xyz`, yere bırakılan eşyanın **CfgVehicles** sınıfıdır (WeaponHolder); envanterdeki gerçek eşya çoğu zaman **CfgWeapons**'taki ön eksiz `Xyz`'dir.
Bu yüzden ayarda `Item_CAC_Card` yazılı olsa bile **hem `Item_CAC_Card` hem `CAC_Card`** kabul edilir. Hangisinin gerçek olduğunu görmek için oyunda:

```sqf
[] call TC2_fnc_debugInfo;   // "aday" satırlarında CfgWeapons=true/false yazar; çıktı panoya da kopyalanır
```

İkisi de `CfgWeapons=false` ise kartı sağlayan mod yüklü değildir ya da sınıf adı farklıdır. Geçici olarak ayarı `ItemGPS` gibi mevcut bir eşyaya çevirip test edebilirsin.
Projenin kendi kartı **`TC2_CAC_Card`** her zaman kabul edilir; ayar yalnızca **ek** (harici mod) kart sınıfları içindir.

### CBA ayarları (`Options > Addon Options > Tactical C2 Network > Terminal ve Erişim (OPSEC)`)

| Ayar | Varsayılan | Kapsam | Açıklama |
|------|-----------|--------|----------|
| `TC2_terminal_enabled` | açık | global | Kapalıysa eylem görünmez, sunucu her talebi reddeder |
| `TC2_access_cardClasses` | `Item_CAC_Card` | global | **Ek** kart sınıf(lar)ı (`TC2_CAC_Card` her zaman geçerli); `;` veya `,` ile ayır |
| `TC2_access_authTime` | 2 sn | global | Kart okutma çubuğu süresi; 0 = anında |
| `TC2_debug` | kapalı | istemci | Bildirimleri sohbet satırına da yazar |

### MP mantığı (server / client)

| Adım | Nerede | Nasıl |
|------|--------|-------|
| CBA ayarları | **tüm makineler** | `XEH_preInit`; global ayarlar sunucudan istemciye senkron |
| ACE eylemi | **istemci** | `XEH_postInit` + `hasInterface`; eylem **sınıfa** bağlı → JIP/respawn için ek iş yok |
| Ön kontrol (kart var mı) | istemci | yalnızca kolaylık (kartsız oyuncu 2 sn beklemesin); **yetki değildir** |
| Erişim kararı | **sunucu** | `TC2_fnc_accessServerHandle` → `TC2_fnc_accessCheck`; istemciden `remoteExecCall` ile **yalnızca sunucuya** |
| Gönderen doğrulama | sunucu | `remoteExecutedOwner` ≠ birimin sahibi → `SENDER_MISMATCH` (başkası adına talep edilemez), yanıt verilmez |
| Denetim kaydı | sunucu RPT | `[TC2][ACCESS] ONAY/RED \| neden=… \| terminal=… \| birim=… \| uid=… \| gonderen=… \| mesafe=…` |
| Yanıt | sunucu → talep eden istemci | `remoteExecCall` yalnızca o makineye; host/SP'de doğrudan çağrı |
| Zaman aşımı | istemci | 8 sn yanıt yoksa talep bırakılır, menü tekrar açılır (sunucuda mod yoksa görünür) |
| JIP | — | durum tutulmaz; terminal global obje, eylem sınıfa bağlı. `TC2_terminalId` global `setVariable` ile JIP'e iletilir |

**Performans:** `onEachFrame` / `waitUntil` döngüsü yok. ACE koşul kodu yalnızca menü terminale bakarken çalışır ve ucuzdur.
İlerleme çubuğu ACE'in kendi CBA PerFrameHandler'ıdır; zaman aşımı `CBA_fnc_waitAndExecute` ile tek seferliktir.

**`CfgRemoteExec`:** `config.cpp` iki fonksiyonu beyaz listeye ekler (`accessServerHandle` yalnızca sunucuya, `accessResult` herkese —
hosted MP'de host hem sunucu hem istemcidir). Sunucu kendi `description.ext`'inde `CfgRemoteExec` `mode = 1` kullanıyorsa ve bu iki fonksiyon
çalışmıyorsa, aynı iki sınıfı oraya da ekle.

**Güvenlik notu:** İstemcide arayüzün açılması tek başına koruma değildir. Gizli içerik (OPORD, INTSUM, Aşama 6) istemcide durmayacak;
sunucu doğrulamasından sonra sunucudan gönderilecek.

### Test

Tek başına test (editör → hosted MP → yerel dedicated + JIP): [`docs/TEST_ASAMA1.md`](docs/TEST_ASAMA1.md)

### Sorun giderme

| Belirti | Olası neden / çözüm |
|---------|---------------------|
| Başlangıçta "requires addon A3_Structures_F_Items_Electronics" | Vanilla yama adı oyun sürümünde farklı; RPT'deki mesajı bana ilet, `requiredAddons` düzeltilir |
| Ana menüde "Tactical C2 Network" ayar kategorisi yok | `@TC2` yüklenmemiş / PBO'da config hatası; RPT'de `tc2_main` ara |
| Terminali Eden'de bulamıyorum | F6 Objects → **Tactical C2 Network**; Zeus'ta addon'u aktive et (`units[]` listeli) |
| ACE menüsünde eylem yok | Terminale 2.5 m içinde bak; `TC2_terminal_enabled` açık mı; `[] call TC2_fnc_debugInfo` ile terminal görünüyor mu |
| Kartım var ama hep "kart bulunamadı" | `[] call TC2_fnc_debugInfo` → `aday` satırları ve `items`; gerçek sınıfı ayara yaz |
| "SUNUCU YANIT VERMEDİ" | Sunucuda `@TC2` yok ya da `CfgRemoteExec` kısıtı (yukarıya bak); sunucu RPT'sinde `[TC2][ACCESS]` var mı |
| Script hatası | `-showScriptErrors` ile başlat; `%LOCALAPPDATA%\Arma 3\*.rpt` içinde `TC2_` / `[TC2]` ara |
