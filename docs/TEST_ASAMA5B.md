# Aşama 5B — topçu (CFF / FDC) testi (tek kişilik)

Doktrin: `docs/DOKTRIN_NOTLARI_TOPCU.md` (ATP 3-09.30). Gerekenler: Aşama 1-4 çalışıyor, ACRE telsizi, terminal **ya da saha cihazı** (laptop gerekmez).
Roller: **gözlemci** (FO/JFO; JTAC de CFF gönderebilir) ve **FDC operatörü**. Atış: topçu araçları OTOMATİK bulunur; **AI topçu YOK (kaldırıldı)**. Yalnızca oyuncu mürettebatlı toplar (ya da TEST için simüle mürettebat)
kullanılır; ateş emri oyunculara bildirilir, **FDC SHOT / SPLASH / ROUNDS COMPLETE'i elle girer**.

## Akış (özet)

`GÖZLEMCİ`: TOPÇU sekmesinde CFF formu ⇒ GÖNDER ⇒ `FDC`: FDC sekmesinde kuyrukta görür ⇒ batarya seçip **KABUL (MTO)** ya da RED ⇒
sistem **MTO / SHOT / SPLASH / ROUNDS COMPLETE** satırlarını üretir ⇒ `GÖZLEMCİ` düzeltme gönderir (DIRECTION, LEFT/RIGHT, ADD/DROP, UP/DOWN, ADJUST/FFE),
`REPEAT`, `FIRE` (AT MY COMMAND), `CHECK FIRING` ⇒ gözetim yapıp **END OF MISSION** (+ RECORD AS TARGET).

## Hazırlık (tek başına)

1. CBA: `Tactical C2 Network → Topçu (CFF / FDC)` ⇒ **TEST: CFF'i kendine (FDC olarak) gönderebil** AÇ.
2. Rolleri ver. Zeus modülleriyle (**Gözlemci (FO/JFO) Ata / Kaldır**, **FDC Operatörü Ata / Kaldır**) ya da hızlıca (Local Exec):
   ```sqf
   player setVariable ["TC2_observer", true, true];
   player setVariable ["TC2_fdc", true, true];
   ```
3. Bir havan kur ve **simüle mürettebat** işareti koy (host Local Exec / dedicated Server Exec; dedicated'de `player` yerine `(allPlayers select 0)`):
   ```sqf
   TC2_gun = createVehicle ["B_Mortar_01_F", player getPos [300, 180], [], 0, "NONE"];
   [TC2_gun] call TC2_fnc_debugArtyCrew;
   ```
   (BLUFOR Mk6 havan, mürettebatsız ama TEST için kullanılabilir sayılır. Gerçek oyunda havana oyuncu biner.)
4. Terminal ya da **Saha Cihazı** ile gir. **HARİTA** sekmesinde, **sizden 600 m'den uzak** (danger close olmasın) ve havandan ~800-3000 m uzakta
   bir `DÜŞMAN PİYADE` işareti koyun.

## A. Temel görev: ADJUST FIRE

1. **TOPÇU** sekmesi (gözlemci yetkisi olmalı). FDC = `SEN (TEST)`; GÖREV = `ADJUST FIRE`; KONUM YÖNTEMİ = `GRID`; HEDEF = işaret;
   HEDEF TANIMI = `PIYADE TAKIMI`; KORUMA = `AÇIKTA`; DÜZELTME TÜRÜ = `ALAN`; DANGER CLOSE = `YOK`; YÖRÜNGE = `YÜKSEK AÇI` (havan);
   MÜHİMMAT = `HE`; HACİM = `2`; KONTROL = `FIRE WHEN READY` ⇒ **GÖNDER (CFF)**.
   Beklenen: `CFF #1 iletildi | FDC: SEN (TEST)`; panel B'ye geçilir; günlükte `…, bu <çağrı adı>, ADJUST FIRE, GRID …, OVER.`
2. **FDC** sekmesi: kuyrukta `#1`, sağda CFF ayrıntısı (AKTARIM 1/2/3, ANGAJMAN, KONTROL). BATARYA = havan; **KABUL (MTO)**.
   Beklenen (gözlemci günlüğü): `MTO, <batarya>, CFF AYNEN, 2 ROUNDS, TARGET AF1001, BREAK, DIRECTION <mil>, OVER.` ⇒ havan **1 mermi** atar (adjust'ta tek top, tek mermi) ⇒
   `SHOT, OUT.` ⇒ `SPLASH, OVER.` (yüksek açı) ⇒ `ROUNDS COMPLETE, OUT.` Durum: `GÖZLEM (düzeltme bekleniyor)`.
3. **Düzeltme** (TOPÇU panel B): mermi nereye düştü, gözleyin. Örn. `SOL(-)/SAĞ(+) = 40`, `DROP(-)/ADD(+) = 100`, YENİ GÖREV = `FIRE FOR EFFECT` ⇒ **DÜZELT**.
   Beklenen: `RIGHT 40, ADD 100, FIRE FOR EFFECT, OVER.` ⇒ havan hacim (2) mermi atar ⇒ `SHOT`, `SPLASH`, `ROUNDS COMPLETE`. Durum: `GÖZETİM (EOM bekleniyor)`.
4. **END OF MISSION:** EOM kutusuna `PIYADE IMHA EDILDI`, KAYIT = `RECORD AS TARGET` ⇒ **END OF MISSION**. Günlük: `RECORD AS TARGET, END OF MISSION, … OVER.`

## B. Konum yöntemleri

- **POLAR:** yeni görev, YÖNTEM = `POLAR`, F1 yön (mil; 1° ≈ 17.78 mil), F2 mesafe (m), F3 dikey. Konum, **gözlemcinin** konumundan hesaplanır. FDC ayrıntısında `HESAPLANAN KONUM` görünür.
- **SHIFT:** A4'te `RECORD AS TARGET` yapıldıysa `HEDEF AF1001` seçeneği çıkar. YÖNTEM = `SHIFT`, HEDEF/NOKTA = `HEDEF AF1001` (ya da bir işaret), F1 yön, F2 sol(-)/sağ(+), F3 drop(-)/add(+), F4 down(-)/up(+).

## C. Doktrin kuralları (sunucu zorlar)

| Test | Beklenen |
|------|----------|
| Hedef **sizden 600 m içinde** + DANGER CLOSE = YOK, GÖNDER | `DANGER CLOSE gerekli: dost <m> m…` reddi |
| Aynısı DANGER CLOSE = VAR | kabul edilir |
| DANGER CLOSE'ta panel B `ADD 300` | `DANGER CLOSE: menzil düzeltmesi en çok 100 m (creeping fire)` |
| `IMMEDIATE SUPPRESSION` seçilince KONTROL | `FIRE WHEN READY`'ye kilitlenir (AT MY COMMAND yok) |
| `SUPPRESS`, SÜRE = 0 | `SUPPRESS için süre (DURATION) verilmeli` |
| YÖNTEM POLAR, yön 7000 | `yön 0-6399 mil olmalı` |
| TOPÇU sekmesi, gözlemci yetkisi yok | `GÖZLEMCİ YETKİSİ GEREKLİ` |
| 30 m'den küçük sapma (örn. SAĞ 20) | uygulanır + `minör` uyarı satırı |
| Başka CFF gönderince | önceki etkin görev `CANCELLED` |

## D. AT MY COMMAND ve CHECK FIRING

- KONTROL = `AT MY COMMAND`; FDC KABUL ⇒ günlük `<batarya> IS READY, OVER.` ⇒ gözlemci **FIRE (AMC)** ⇒ `FIRE, OUT.` ⇒ atış.
- Atış sürerken **CHECK FIRING** (gözlemci ya da FDC) ⇒ `CHECK FIRING. Atış durduruldu.` (mermi havadaysa düşer.)

## E. Oyuncu mürettebat (AI topçu yok)

- **AI mürettebat / mürettebatsız top:** `debugArtyCrew` işareti olmayan, AI mürettebatlı ya da boş bir top kullanılamaz: FDC KABUL ⇒ `Bu bataryada oyuncu mürettebat yok (AI topçu desteklenmez)`. Batarya listesinde `(OYUNCU YOK)`.
- **Oyuncu mürettebatlı:** havana binin (gunner) ⇒ FDC KABUL ⇒ size bildirim + sohbet: `ATEŞ EMRİ #1: <batarya> x N mermi (<şarjör>) | hedef GRID … | azimut … mil | mesafe … m`.
  Bu bataryada **SHOT / SPLASH / ROUNDS COMPLETE** düğmeleri FDC'de etkindir ve **elle** basılır (oyuncu mermisini sistem sayamaz).

## F. Dedicated

Aynı adımlar. Sunucu RPT'sinde `[TC2][TOPCU]` satırları (CFF, KABUL, EOM, RED). Anti-sahtecilik: istemciden başkası adına gönderim denemesi `SENDER_MISMATCH` almalı:
```sqf
[(allUnits select {!isPlayer _x}) select 0, objNull, [], [], ""] remoteExecCall ["TC2_fnc_artySendCff", 2];
```

## Beklenen sonuç özeti

| Test | Beklenen |
|------|----------|
| A1-A4 | tam görev döngüsü: CFF → MTO → SHOT/SPLASH/ROUNDS COMPLETE → düzeltme → FFE → EOM |
| B | POLAR / SHIFT konumları çözülür |
| C | danger close, creeping, immediate, duration kuralları zorlanır |
| D | AT MY COMMAND (IS READY → FIRE), CHECK FIRING |
| E | oyuncu yok ⇒ kullanılamaz; oyuncu bataryasında ateş emri + elle bildirimler |
