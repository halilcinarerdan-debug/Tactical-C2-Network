# Aşama 2 — terminal arayüzü testi

Hazırlık Aşama 1 ile aynı (`docs/TEST_ASAMA1.md`): PBO'yu yeniden derle, `-showScriptErrors` ile başlat.
Kartı al: `[player, true] call TC2_fnc_debugCard;`

| # | Test | Beklenen |
|---|------|----------|
| 1 | Terminale giriş yap (kart + ilerleme çubuğu) | Ekranın ortasında yeşil/siyah pencere açılır. Başlık: `TC2 KOMUTA TERMİNALİ | <terminal> | <adın>` |
| 2 | ANA sekmesi | Kullanıcı, birlik, terminal, kimlik DOĞRULANDI, ağ/yetki "belirlenmedi" satırları |
| 3 | Sekmelere tıkla (HARİTA, CAS, İSTİHBARAT, LOJİSTİK, UAV) | Seçili sekme açık yeşil olur; içerikte hangi aşamada geleceği yazar |
| 4 | **KAPAT** düğmesi | Pencere kapanır |
| 5 | **ESC** | Pencere kapanır, duraklatma menüsü açılmaz |
| 6 | Pencere açıkken karakter | Yerinde durur (WASD çalışmaz), oyun akar |
| 7 | Kartı çek. Önce şu komutu çalıştır, **12 sn içinde** terminale girip pencereyi aç: `[{[player,false] call TC2_fnc_debugCard},[],12] call CBA_fnc_waitAndExecute;` | Kart silinince ≤ 1 sn içinde pencere kapanır: "Oturum sonlandırıldı. ERİŞİM REDDEDİLDİ: Kimlik kartı…" |
| 8 | Uzaklaşma. Önce çalıştır, **12 sn içinde** pencereyi aç: `[{player setPosATL ((getPosATL player) vectorAdd [8,0,0])},[],12] call CBA_fnc_waitAndExecute;` | Pencere kapanır, "Terminale çok uzaksınız" |
| 9 | Ölüm. Önce çalıştır, **12 sn içinde** pencereyi aç: `[{player setDamage 1},[],12] call CBA_fnc_waitAndExecute;` | Pencere kapanır |
| 10 | Temizlik: pencereyi kapattıktan sonra `[missionNamespace getVariable "TC2_ui_watchHandle", isNull (missionNamespace getVariable ["TC2_terminal_current", objNull])]` | `[-1,true]` |
| 11 | Art arda 5 kez aç/kapat | Hata yok, pencere her seferinde tek, kapanınca izleme (PFH) kalmıyor (#10 her seferinde `[-1,true]`) |
| 12 | Dedicated + istemci (Aşama 1, bölüm 3) | Aynı davranış; pencere yalnızca sunucu ONAY verdikten sonra açılır, RPT'de `[TC2][ACCESS] ONAY` |

Notlar:
- Yazılar bozuk çıkıyorsa (Türkçe harf kutucuğa dönüşmesi) bana bildir; yazı tipi tek yerden değiştirilebilir.
- Pencere boyutu ekranın %70'i. Küçük/büyük ekranda orantı bozulursa `fn_uiOpen.sqf` başındaki `_w`/`_h` çarpanını değiştir.
