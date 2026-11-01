# Aşama 6 — OPORD (yetki seviyeli belge) testi

Doktrin: [`DOKTRIN_NOTLARI_OPORD.md`](DOKTRIN_NOTLARI_OPORD.md) (JP 3-0). OPORD **sunucuda** durur; her kullanıcıya yalnızca **seviyesinin görebildiği** bölümlerin METNİ gönderilir
(gizli bölümün sadece başlığı ve gereken seviye gider). Okuma için fiziksel terminalde telsiz gerekmez; **saha cihazında** telsiz ağı gerekir.

## Seviye ver (tek başına)

Local Exec (sırayla deneyin):
```sqf
player setVariable ["TC2_level", 3, true];   // komuta: düzenler, her şeyi görür
player setVariable ["TC2_level", 2, true];   // lider/rol: Seviye 3 bölümleri GİZLİ
player setVariable ["TC2_level", 1, true];   // herkes: yalnız Seviye 1 bölümler
player setVariable ["TC2_level", nil, true]; // açık atamayı kaldır -> rütbe / grup lideri / rol kuralı
```
(Rütbeyle: CBA `Belgeler ve Yetki (OPORD)` ⇒ Level 2 / Level 3 için en düşük rütbe. Varsayılan ÇAVUŞ / TEĞMEN; grup lideri ve JTAC / gözlemci / FDC = en az Level 2.)

## A. Belge oluşturma ve düzenleme (Level 3)

1. Terminalde **OPORD** sekmesi. Belge yoksa: *"Henüz yayımlanmış OPORD yok…"* ve **ŞABLON OLUŞTUR** düğmesi (yalnız Level 3).
2. **ŞABLON OLUŞTUR** ⇒ beş paragraf şablonu: GÖREV ORGANİZASYONU, 1.a-1.e, 2, 3.a-3.h (+ 3.g.1 CCIR), 4, 5.a-5.c, EK D. Üst bilgi: başlık, DTG, etiket, **SÜRÜM 1**, **YETKİNİZ: Level 3**, ONAY: 0.
3. Soldaki listeden bir bölüm seçin ⇒ metin kaydırılabilir alanda görünür (fare tekerleği).
4. **DÜZENLE** ⇒ düzenleme alanı açılır; metni değiştirin, **BÖLÜM SEVİYESİ** (1/2/3) seçin, **KAYDET** ⇒ *"Bölüm kaydedildi (sürüm 2)."* Sürüm artar. Ağdaki oturumların günlüğüne `OPORD güncellendi (sürüm 2): bölüm 3A` düşer.
5. **OKUMA MODU** ile geri dönün.

## B. Seviye filtresi (asıl güvenlik özelliği)

1. Level 3 ile bazı bölümlere farklı seviyeler verin (örn. `5C` HABERLEŞME = 3, `1B` DÜŞMAN = 2).
2. Seviyeyi **2** yapın (`TC2_level` = 2), sekmeyi kapatıp açın (ya da 5 sn bekleyin). Beklenen:
   - Level 3 bölümler listede **`[GİZLİ - Level 3]  5.c HABERLEŞME`** olarak görünür; seçince *"Bu bölümü görme yetkiniz yok. Gereken: Level 3  Sizin seviyeniz: Level 2"*.
   - **DÜZENLE / KAYDET** düğmeleri görünmez.
3. **Metnin istemcide olmadığını doğrulayın** (Local Exec): `(TC2_opord_data select 3) apply {_x select 0}` ⇒ görünür bölüm anahtarları; `"5C"` listede **OLMAMALI**.
4. Seviye **1** ⇒ yalnız Seviye 1 bölümler açık.
5. Kurcalama denemesi: Level 2 iken Local Exec ile sunucuya `SAVE` göndermeyi deneyin:
   `[ACE_player, TC2_terminal_current, [], "SAVE", ["3A", 1, "x"]] remoteExecCall ["TC2_fnc_opordEdit", 2];` ⇒ sunucu RPT: `[TC2][OPORD] RED: duzenleme yetkisi yok`, istemciye *"OPORD'u yalnızca Level 3 düzenleyebilir."*

## C. Onay (OKUDUM / ANLADIM)

Herhangi bir seviyeden **OKUDUM / ANLADIM** ⇒ *"OPORD onayınız kaydedildi (sürüm N)."*, düğme **ONAYLANDI** olur. Level 3 üst bilgide `ONAY: n` görür.
Metin değişip sürüm artınca onay yeniden istenir (o sürüm için sayılır). Sunucu RPT: `[TC2][OPORD] ONAY | <ad> | surum=N | seviye=L`.

## D. Mission dosyasından yükleme

`docs/ornek_tc2_opord.sqf`'i mission klasörüne **`tc2_opord.sqf`** adıyla koyun (mission.sqm'nin yanına). Mission'ı başlatın ⇒ sunucu RPT: `[TC2][OPORD] yayimlandi 'OPERASYON EMRI 01' | 6 bolum`.
OPORD sekmesinde belge hazır gelir (SÜRÜM 1); Level 1'de yalnız Seviye 1 bölümler (GÖREV, NİYET) görünür.

## E. Saha cihazı ve dedicated

- **Saha cihazı** (ACE self menü ⇒ TC2 Saha Cihazı) ile aynı sekme; telsiz yoksa *BAĞLANTI YOK*. Fiziksel terminalde telsiz olmasa da okunur.
- **Dedicated:** aynı adımlar. Sunucu RPT'sinde `[TC2][OPORD]` satırları (yayımlama, güncelleme, onay, ret). JIP: oyuna sonradan giren terminali açınca belgeyi sunucudan alır.

## Beklenen sonuç özeti

| Test | Beklenen |
|------|----------|
| A | şablon oluşur; KAYDET sürümü artırır; ağa bilgi satırı gider |
| B | Level 2/1'de üst seviye bölümlerin yalnız başlığı görünür; metin istemcide YOK; yetkisiz SAVE reddedilir |
| C | onay kaydedilir; Level 3 onay sayısını görür |
| D | `tc2_opord.sqf` mission başında yüklenir |
| E | saha cihazında telsiz şartı, terminalde yok |
