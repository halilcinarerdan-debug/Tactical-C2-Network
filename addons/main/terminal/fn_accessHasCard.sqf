/*
    Fonksiyon: TC2_fnc_accessHasCard
    Çalışma yeri: Her makine (saf fonksiyon, yan etkisi yok)

    Birimin kimlik kartı var mı? Üniforma + yelek + sırt çantası eşyaları ve atanmış eşyalar
    (items + assignedItems) taranır; karşılaştırma büyük/küçük harfe duyarsızdır.

    MP notu: envanter tüm makinelere senkronlanır, bu yüzden SUNUCU da başka oyuncunun kartını
    doğru görür. Sunucu bu fonksiyonla kendi kararını verir (istemciye güvenilmez).

    Güvenli varsayılan (fail-closed): kart sınıfı ayarı boşsa kimse giremez.

    Parametreler:
        0: birim <OBJECT>

    Dönüş: <BOOL>
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {false};

private _wanted = [] call TC2_fnc_accessGetCardClasses;
if (_wanted isEqualTo []) exitWith {false};

private _have = (items _unit + assignedItems _unit) apply {toLower _x};

// Kesişim boş değilse en az bir aday kart envanterde.
(count (_wanted arrayIntersect _have)) > 0
