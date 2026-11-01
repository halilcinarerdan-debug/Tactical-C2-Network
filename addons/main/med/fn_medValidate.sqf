/*
    Fonksiyon: TC2_fnc_medValidate
    Çalışma yeri: Her makine (saf fonksiyon). Sunucu KARAR için, istemci anında geri bildirim için çağırır.

    9-Line MEDEVAC talebini denetler. Veri 14 METİN:
      0 konum anahtarı ("OWN" | "M<işaret id>")         [Satır 1]
      1 ek not (frekans / çağrı adı eki, isteğe bağlı)   [Satır 2]
      2..6 hasta sayısı, öncelik A (acil), B (acil-cerrahi), C (öncelikli), D (rutin), E (kolaylık): "0".."9"   [Satır 3]
      7 özel ekipman: A yok, B vinç, C kurtarma ekipmanı, D ventilatör   [Satır 4]
      8 sedyeli (L), 9 yürüyebilen / oturan (A) hasta sayısı: "0".."9"   [Satır 5]
      10 güvenlik: N düşman yok, P olası düşman, E düşman var, X silahlı eskort gerekli   [Satır 6]
      11 işaretleme: A panel, B piroteknik, C duman, D yok, E diğer   [Satır 7]
      12 uyruk / durum: A dost asker, B dost sivil, C dost dışı asker, D dost dışı sivil, E düşman esir   [Satır 8]
      13 CBRN: "" (yok) | N | B | C   [Satır 9]
    Tutarlılık kuralı: Satır 3 toplamı = Satır 5 toplamı (>= 1).

    DOKTRİN DAYANAĞI: ATP 3-21.8 8-46: "9-line MEDEVAC isteği (GTA 08-01-004) hava ambulansı istemenin standart yöntemidir." Dokuz satırın İÇERİĞİ
    yüklenen dokümanlarda YOKTUR; yukarıdaki biçim genel bilgidir (savaş zamanı sürümü) ve doğrulanmamıştır (bkz. docs/DOKTRIN_NOTLARI_MEDEVAC.md).

    Parametreler:
        0: veri <ARRAY of STRING>

    Dönüş: [geçerli mi <BOOL>, hatalar <ARRAY of STRING>]
*/

params [["_data", [], [[]]]];

if (count _data != 14 || {count (_data select {!(_x isEqualType "")}) > 0}) exitWith {[false, ["Geçersiz MEDEVAC verisi."]]};

private _errors = [];
private _number = {parseNumber _this};
private _isCount = {_this in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]};

private _location = _data select 0;
if !(_location isEqualTo "OWN" || {(_location select [0, 1]) isEqualTo "M"}) then {_errors pushBack "Satır 1: alım yeri seçin."};
if (count (_data select 1) > 40) then {_errors pushBack "Satır 2: not en çok 40 karakter."};

private _total = 0;
{
    private _value = _data select _x;
    if !(_value call _isCount) then {_errors pushBack "Satır 3: sayı 0-9 olmalı."} else {_total = _total + (_value call _number)};
} forEach [2, 3, 4, 5, 6];

if !((_data select 7) in ["A", "B", "C", "D"]) then {_errors pushBack "Satır 4: özel ekipman seçin."};

private _typed = 0;
{
    private _value = _data select _x;
    if !(_value call _isCount) then {_errors pushBack "Satır 5: sayı 0-9 olmalı."} else {_typed = _typed + (_value call _number)};
} forEach [8, 9];

if (_total < 1) then {_errors pushBack "Satır 3: en az 1 hasta."};
if (_total != _typed) then {_errors pushBack format ["Satır 3 (%1 hasta) ile Satır 5 (%2 hasta) eşleşmeli.", _total, _typed]};

if !((_data select 10) in ["N", "P", "E", "X"]) then {_errors pushBack "Satır 6: güvenlik durumu seçin."};
if !((_data select 11) in ["A", "B", "C", "D", "E"]) then {_errors pushBack "Satır 7: işaretleme yöntemi seçin."};
if !((_data select 12) in ["A", "B", "C", "D", "E"]) then {_errors pushBack "Satır 8: uyruk / durum seçin."};
if !((_data select 13) in ["", "N", "B", "C"]) then {_errors pushBack "Satır 9: CBRN geçersiz."};

[_errors isEqualTo [], _errors]
