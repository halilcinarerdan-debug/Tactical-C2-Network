# Aşama 1 — tek başına test rehberi

Yanında kimse olmadan test etmek için üç kademe var. Önce 1. kademe (hızlı), sonra 2. ve 3. (gerçek MP).

| Kademe | Nasıl | Neyi kanıtlar | Neyi **kanıtlamaz** |
|--------|-------|---------------|---------------------|
| 1. Editör (SP) | Eden → Play | mantık, mesajlar, kart kontrolü | ağ, locality |
| 2. Hosted MP | Eden → Play → In Multiplayer | MP ortamında çalışma | **uzak istemci yolu**: host aynı zamanda sunucu olduğundan istemci→sunucu `remoteExec` hiç kullanılmaz (doğrudan çağrı) |
| 3. Yerel dedicated + 1 istemci | Aynı PC'de `arma3server_x64.exe` + `arma3_x64.exe` | **gerçek ağ yolu**, gönderen doğrulama, denetim kaydı, JIP | — |

> Neden 3. kademe şart? Hosted MP'de host hem sunucu hem istemcidir; locality hataları (ör. sadece host'ta çalışan kod) gizli kalır.
> Dedicated sunucu + ayrı istemci, ikinci bir oyuncu olmadan da gerçek sunucu/istemci ayrımını ve JIP'i sınar.

Genel ipuçları:
- Oyunu `-showScriptErrors` ile başlat. Script hataları ekranda çıkar; ayrıntı `%LOCALAPPDATA%\Arma 3\*.rpt` içindedir (`[TC2]` ara).
- Debug konsolunda: **Local Exec** = senin makinen, **Server Exec** = yalnızca sunucu, **Global Exec** = herkes. Sonuç satırı son ifadenin değerini gösterir.
- Her kod değişikliğinden sonra PBO'yu yeniden derle; oyun açıkken PBO değiştirilemez.

---

## 0. Hazırlık

1. `@TC2` derle (README → "Mikero ile derleme"). Başlatma: `-mod=@CBA_A3;@ace;@TC2 -showScriptErrors`
2. Ana menü → **Options → Addon Options**: **Tactical C2 Network** kategorisi görünmeli.

## 1. Editör testi (SP)

**Kurulum.** Eden'de VR haritası (Stratis/Altis de olur) → bir oyuncu birimi koy.
**F6 (Objects) → Tactical C2 Network → Terminals → TC2 Command Terminal**'i oyuncunun ~1.5 m önüne koy
(yere ya da bir masaya). **Play**.

**1.1 Yükleme doğrulaması** (Debug konsolu, Local Exec):

```sqf
[isClass (configFile >> "CfgPatches" >> "tc2_main"), isClass (configFile >> "CfgVehicles" >> "TC2_Terminal_F"), !isNil "TC2_fnc_accessCheck"]
```
Beklenen: `[true,true,true]`.

**1.2 Kart sınıfını doğrula** (Local Exec):

```sqf
[] call TC2_fnc_debugInfo;
```
Çıktı sohbet satırına yazılır ve **panoya kopyalanır** (bana yapıştırabilirsin). `aday` satırlarına bak:
`item_cac_card` ve/veya `cac_card` için `CfgWeapons=true` olan bir sınıf olmalı. İkisi de `false` ise kartı sağlayan mod yüklü değil
ya da sınıf adı farklı; geçici çözüm: `Options → Addon Options → Tactical C2 Network` içinde **Gerekli kimlik kartı** ayarını `ItemGPS` yap
(aşağıdaki testlerin hepsi aynen geçerli).

**1.3 Senaryo A — kart yok ⇒ RED.** Kartın olmadığından emin ol: `[player, false] call TC2_fnc_debugCard;`.
Terminale bak, **Sol Windows**'u basılı tut (ACE etkileşim), **Terminale Giriş (Kimlik Kartı)**'nı seç
(eylem terminalin ACE "Interactions" noktasının altında gelir).
Beklenen: **anında** kırmızı mesaj *"ERİŞİM REDDEDİLDİ: Kimlik kartı (CAC) bulunamadı."* (ilerleme çubuğu çıkmaz).

**1.4 Senaryo B — kart var ⇒ ONAY.** `[player, true] call TC2_fnc_debugCard;` (yeşil "Kart verildi" mesajı), tekrar eylemi seç.
Beklenen: 2 sn'lik *"Kimlik doğrulanıyor..."* çubuğu, sonra yeşil *"ERİŞİM ONAYLANDI. Terminal: <kimlik>. (Arayüz Aşama 2'de eklenecek.)"*.
Çubuk sırasında terminalden uzaklaşırsan (>4 m) çubuk iptal olur: *"Kimlik doğrulama iptal edildi."*

**1.5 Sunucu kararı kartı yeniden denetliyor mu?** (İstemci ön kontrolünü geçip sunucuda düşme senaryosu.) Local Exec:

```sqf
TC2_t = (nearestObjects [player, ["TC2_Terminal_F"], 20]) select 0;
[player, true] call TC2_fnc_debugCard;
[TC2_t, player] call TC2_fnc_accessRequest;                                          // kart var → çubuk başlar
[{[player, false] call TC2_fnc_debugCard}, [], 0.5] call CBA_fnc_waitAndExecute;     // çubuk sürerken kartı sil
```
Beklenen: çubuk biter, **sunucu** kartı bulamaz ⇒ kırmızı *"ERİŞİM REDDEDİLDİ: Kimlik kartı (CAC) bulunamadı."*
RPT'de (`-showScriptErrors` açık oyunun RPT'si; SP'de sunucu = sen): `[TC2][ACCESS] RED | neden=NO_CARD | ...`

**1.6 Sunucu kontrolünü AI ile dene** (saf fonksiyon `accessCheck`; ikinci bir oyuncuya gerek yok). Local Exec, sırayla:

```sqf
TC2_t  = (nearestObjects [player, ["TC2_Terminal_F"], 20]) select 0;
TC2_ai = (createGroup west) createUnit ["B_Soldier_F", TC2_t getPos [1.5, 0], [], 0, "NONE"];
[TC2_ai, true] call TC2_fnc_debugCard;
systemChat str ([TC2_t, TC2_ai] call TC2_fnc_accessCheck);      // beklenen: [true,"OK"]
```
```sqf
[TC2_ai, false] call TC2_fnc_debugCard;
systemChat str ([TC2_t, TC2_ai] call TC2_fnc_accessCheck);      // beklenen: [false,"NO_CARD"]
```
```sqf
[TC2_ai, true] call TC2_fnc_debugCard;
TC2_ai setPosATL ((getPosATL TC2_t) vectorAdd [8, 0, 0]);
systemChat str ([TC2_t, TC2_ai] call TC2_fnc_accessCheck);      // beklenen: [false,"TOO_FAR"]
```
```sqf
TC2_ai setPosATL ((getPosATL TC2_t) vectorAdd [1.5, 0, 0]);
TC2_ai setDamage 1;
systemChat str ([TC2_t, TC2_ai] call TC2_fnc_accessCheck);      // beklenen: [false,"DEAD"]
```
(İsteğe bağlı: canlı bir AI'a `setUnconscious true` verince `UNCONSCIOUS` dönmesi beklenir; dönmezse bana bildir.)

**1.7 Ayarlar.** `TC2_terminal_enabled`'ı kapat ⇒ eylem menüden kaybolur ve `accessCheck` `DISABLED` döner. `TC2_access_authTime`'ı 0 yap ⇒ çubuk çıkmadan anında sonuç.
`TC2_access_cardClasses` boşalt ⇒ kartı olan bile giremez (güvenli varsayılan).

## 2. Hosted MP

Eden'de oyuncu birimi **Player/Playable** olsun. **Play → Play Scenario → In Multiplayer**. 1.3–1.7'yi tekrarla.
Bu kademede `Server Exec` de sana (host) çalışır. Çalışma zamanında terminal yaratmak için (Server Exec):

```sqf
[(getPosATL (allPlayers select 0)) vectorAdd [2, 0, 0], 90, "TOC-TEST"] call TC2_fnc_terminalCreate;
```
Not: sunucuda `player` null olduğu için konum `allPlayers` ile alınır. Yeni terminalde eylem görünmeli.

## 3. Yerel dedicated sunucu + 1 istemci (gerçek ağ yolu)

Yollar örnektir; kendine göre uyarla. BattlEye kapalı denenir.

**3.1 Test mission'ı.** Eden'de: 1 oyuncu birimi (**Playable**), 1 terminal, **1 AI** (anti-sahtecilik testi için). Mission klasörüne
`description.ext` ekle:

```cpp
enableDebugConsole = 1;   // 1 = admin (sunucuya #login ile girilince)
```
**Scenario → Export → Export to Multiplayer** ile PBO üret (ör. `TC2_Test.VR.pbo`) ve `<Arma 3 kurulum>\MPMissions\` içine koy.

**3.2 `C:\a3srv\server.cfg`** (örnek):

```cpp
hostName = "TC2 Test";
password = "";
passwordAdmin = "admin123";
serverCommandPassword = "cmd123";
maxPlayers = 4;
verifySignatures = 0;
BattlEye = 0;
disableVoN = 1;
class Missions
{
    class TC2Test
    {
        template = "TC2_Test.VR";
        difficulty = "Regular";
    };
};
```

**3.3 Sunucuyu başlat:**

```bat
arma3server_x64.exe -port=2302 -config=C:\a3srv\server.cfg -profiles=C:\a3srv\profile -name=srv -autoInit -mod=@CBA_A3;@ace;@TC2
```

**3.4 İstemciyi aynı PC'de, BattlEye'sız başlat** (doğrudan `arma3_x64.exe`, launcher değil):

```bat
arma3_x64.exe -mod=@CBA_A3;@ace;@TC2 -showScriptErrors -connect=127.0.0.1 -port=2302
```
Oyuna girince sohbete `#login admin123` yaz (debug konsolu açılır). Sunucu RPT'si: `C:\a3srv\profile\` içindeki en yeni `.rpt`.

**3.5 Gerçek ağ yolunu sına.** İstemcide `[player, true] call TC2_fnc_debugCard;` sonra terminale giriş yap.
Beklenen: çubuk ⇒ yeşil ONAY. **Sunucu RPT'sinde**:

```
[TC2][ACCESS] ONAY | neden=OK | terminal=... | birim=<adın> | uid=... | sahip=<N> | gonderen=<N> | mesafe=...m
```
`gonderen` ve `sahip` **aynı sayı** ve 0 değil ⇒ talep gerçekten ağdan (remoteExec) geldi ve gönderen doğrulaması çalıştı.
Kartı alıp tekrar dene (1.3) ⇒ istemci ön kontrolü kırmızı verir, sunucu RPT'sine satır **düşmez** (talep sunucuya hiç gitmez).
1.5'teki senaryoyu burada da çalıştır ⇒ RPT'de `RED | neden=NO_CARD` görmelisin (sunucu istemciye güvenmedi).

**3.6 Anti-sahtecilik testi** (istemcide Local Exec; AI'ın sunucuya ait olması şart, o yüzden mission'daki AI):

```sqf
private _t  = (nearestObjects [player, ["TC2_Terminal_F"], 20]) select 0;
private _ai = (allUnits select {!isPlayer _x}) select 0;
[_t, _ai, 1] remoteExecCall ["TC2_fnc_accessServerHandle", 2];   // "AI adına" erişim iste
```
Beklenen: istemcide **hiçbir mesaj yok**; sunucu RPT'sinde `RED | neden=SENDER_MISMATCH | ... | sahip=2 | gonderen=<senin id'in>`.
(`CfgRemoteExec` kısıtı yüzünden çalışmazsa README'deki nota bak.)

**3.7 Sunucu tarafı terminal yaratma + JIP.** İstemcide Server Exec (ya da `#login` sonrası Debug Console → **Server Exec**):

```sqf
[(getPosATL (allPlayers select 0)) vectorAdd [2, 0, 0], 90, "TOC-TEST"] call TC2_fnc_terminalCreate;
```
- İstemcide `[] call TC2_fnc_debugInfo;` ⇒ "15 m içindeki terminal sayısı" 1 artmalı; yeni terminalde eylem çalışmalı, ONAY mesajında kimlik **TOC-TEST** olmalı.
- **JIP testi:** istemciden çık (ESC → Disconnect), **Multiplayer → Direct Connect → 127.0.0.1:2302** ile tekrar gir.
  Hem mission'daki terminal hem `TOC-TEST` hâlâ etkileşilebilir olmalı ve kimlik `TOC-TEST` görünmeli (global obje + sınıfa bağlı eylem + global `setVariable`).

## Hızlı kontrol listesi

| Test | Beklenen |
|------|----------|
| 1.1 yükleme | `[true,true,true]` |
| 1.3 kart yok | anında kırmızı hata, çubuk yok |
| 1.4 kart var | çubuk → yeşil ONAY |
| 1.5 çubukta kart silindi | sunucu RED (`NO_CARD`) |
| 1.6 AI | `OK`, `NO_CARD`, `TOO_FAR`, `DEAD` |
| 3.5 | RPT: ONAY, `gonderen = sahip ≠ 0` |
| 3.6 | RPT: `SENDER_MISMATCH`, istemcide mesaj yok |
| 3.7 | yeni terminal çalışır, kimlik `TOC-TEST`; yeniden bağlanınca (JIP) hâlâ çalışır |

Takıldığın yerde `[] call TC2_fnc_debugInfo;` çıktısını (panoda) ve sunucu RPT'sindeki `[TC2]` satırlarını bana yapıştır.
