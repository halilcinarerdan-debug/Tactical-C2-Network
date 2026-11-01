# UAV entegrasyonu — düşünme notları (karar bekliyor)

Durum: Aşama 2'de **UAV** sekmesi yalnızca yer tutucudur. Bu belge, neden ve nasıl entegre edileceğine dair öneridir.
Aşağıdaki oyun davranışları Arma 3/ACE bilgisine dayanır, **bu projede henüz denenmedi**; uygulamadan önce küçük bir prototip gerekir.

## Sorun: vanilla UAV terminali "arcade"

- Dost bir İHA'ya bağlanmak için menzil, telsiz veya yetki gerekmez; terminal eşyası yeterlidir.
- Bağlanan oyuncu hemen kamera, hedef işaretleme ve silahları kullanır.
- Bu, projenin OPSEC / yetki / ağ mantığıyla çelişir: "ağ yoksa veri yok" kuralı UAV'de işlemez.

## Seçenekler

| | Yaklaşım | Artı | Eksi |
|---|---|---|---|
| **A (öneri)** | UAV sekmesi *yetki ve bağlantı kapısı* olur: yetkili İHA listesi + durum; "Bağlan" yalnızca yetki **ve** ağ (ACRE2) koşulu sağlanırsa vanilla bağlantıyı (`connectTerminalToUAV`) tetikler | Kamera/kontrol motoru yeniden yazılmaz; performans maliyeti sıfıra yakın | Oyuncuda vanilla UAV terminali eşyası varsa kapıyı atlayabilir → görev tasarımında bu eşya dağıtılmaz / yalnızca TC2 terminalinden bağlanılır |
| B | İHA görüntüsünü terminal penceresine canlı yayın (render-to-texture / PiP) | Terminal içinde "yayın izleme" hissi | Her yayın ek render yükü; basitlik ve performans hedefine ters |
| C | Vanilla'ya dokunma, yalnızca bağlanınca ağ kontrolü yap, kopunca bağlantıyı kes | En az kod | Engelleme geç ve kaba; kullanıcı deneyimi kötü |

## Öneri

**A**, Aşama 3'ten (ACRE2 ağ kontrolü) **sonra**: İHA'ya bağlanma koşulu, 9-Line gibi aynı `ağ + yetki` kontrolünden geçer.
Aşama 2'de sekme, bu planı söyleyen bir not gösterir. Bağlantı/yetki kuralları (hangi seviye, hangi İHA, yayın mı kontrol mü)
sizinle birlikte Aşama 3 sonunda netleştirilecek.

## Açık sorular

1. Terminal yalnızca *yayın izleme* mi versin, yoksa *kontrol* de mi?
2. İHA operatörü ayrı bir rol mü (yalnızca onda UAV terminali var), yoksa herkes yetkiye göre mi bağlanır?
3. Görevlerde ACE'in kendi UAV modülü (varsa) kullanılıyor mu? Çakışma kontrolü gerekir.
