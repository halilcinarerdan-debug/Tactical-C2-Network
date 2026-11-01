# 9-Line MEDEVAC testi

Doktrin ve sınırlar: [`DOKTRIN_NOTLARI_MEDEVAC.md`](DOKTRIN_NOTLARI_MEDEVAC.md). **Satır içerikleri yüklenen dokümanlarda yok, genel bilgidir.**

## Tek başına (simüle helikopter mürettebatı)

Debug konsolu (host: Local Exec). Kendi telsiz tipiniz/kanalınızla aynı olsun:
```sqf
["BLUE"] call TC2_fnc_debugGive;      // Level 2 (gerekirse ["TABLET"] ile tablet de)
TC2_heli = (createGroup west) createUnit ["B_Soldier_F", player getPos [300, 0], [], 0, "NONE"];
[TC2_heli, "ACRE_PRC343", 1, "RW", false] call TC2_fnc_debugCasPilot;   // simüle helikopter mürettebatı
```
1. Terminal (ya da tabletli saha cihazı) ⇒ **MEDEVAC** sekmesi (7. sekme). Form: 1 Alım yeri = Kendi konumum; 3 Hasta/öncelik: `A 1`, `C 2`; 4 ekipman yok; 5 `L 1`, `A 2`; 6 Güvenlik `P`; 7 İşaretleme `C duman`; 8 `A dost asker`; 9 yok.
2. **TALEBİ GÖNDER** ⇒ *"MEDEVAC talebi gönderildi (#1, 1 mürettebat)."*; sağ listede `#1 <çağrı adınız> [AÇIK]`.
3. ~4 sn sonra: bildirim **"MEDEVAC #1 KABUL: SIM-PILOT ..., tahmini varış N dk"**, listede `[KABUL]`, ayrıntıda 9 satır + *KABUL: ... ETA N dk*.
4. **Doğrulama kuralları:** Satır 3 toplamı (3 hasta) ile Satır 5 toplamı (1 + 2 = 3) eşleşmezse ret; 0 hasta ret; ekipman/güvenlik/işaretleme/uyruk seçimi boşsa ret.
5. **İPTAL ET:** yeni talep gönder, sonra listeden seç ⇒ **TALEBİ İPTAL ET** ⇒ durum `[İPTAL]`. Yeni talep göndermek eski etkin talebi de iptal eder.
6. Yetki: `["RED"] call TC2_fnc_debugGive;` ⇒ MEDEVAC sekmesi *"Level 2 ve üstü içindir"*, form yok. Er (tabletli, lider değil) ⇒ sekme soluk; sunucuya zorla çağrı ⇒ `VIEW_ONLY`.
7. Telsiz yok ya da menzil dışı simüle mürettebat (kanalı farklı yapın) ⇒ *"Ağınızda … helikopter mürettebatı yok."*

## Gerçek mürettebat (iki oyuncu)

1. Oyuncu B helikopterde (pilot ya da yolcu), aynı telsiz tipi/kanalda, menzilde.
2. A (Mavi kart / lider+tablet) talebi gönderir.
3. B'de bip + **"MEDEVAC TALEBİ #1 (...)"** bildirimi; güvenlik **E** ise kırmızı "DÜŞMAN VAR" uyarısı.
4. B: ACE self menü (Sol Windows) ⇒ **TC2 MEDEVAC** ⇒ **#1 OKU** (9 satır, ACE yazısıyla 12 sn) ⇒ **#1 KABUL**. B'ye *"kabul edildi, tahmini varış N dk"*, A'ya *"MEDEVAC #1 KABUL: <B çağrı adı> ..."* gider; üçüncü bir mürettebat varsa *"başka mürettebat tarafından alındı"*.
5. Helikopterden inen B menüyü göremez (yalnızca hava aracında görünür). Tabletsiz B'nin kabul etmesi çalışır (hava aracı muafiyeti).
6. Dedicated sunucuda aynı adımlar; sunucu RPT'sinde `[TC2][MEDEVAC] GONDERILDI`, `KABUL`, `IPTAL`.

## Bilinen sınırlar
* Talepler sunucu belleğinde (son 2 saat, en çok 30); sunucu yeniden başlayınca silinir.
* Alım yeri haritada (terminalde) ayrı simgeyle çizilmez; yalnızca satır 1'de grid olarak görünür.
* Yalnızca sqflint ile denendi; oyun içi doğrulama kullanıcı testine bağlıdır.
