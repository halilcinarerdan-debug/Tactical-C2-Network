/*
    Fonksiyon: TC2_fnc_terminalOpen
    Çalışma yeri: İstemci (sunucu erişimi ONAYLADIKTAN sonra accessResult çağırır)

    Terminal arayüzünü açar (TC2_fnc_uiOpen, Aşama 2). Çağıran kod Aşama 1'den beri değişmedi.

    Not (güvenlik tasarımı): Arayüzün istemcide açılması tek başına bir koruma değildir; kurcalanmış
    bir istemci bu fonksiyonu doğrudan çağırabilir. Bu yüzden gizli içerik (OPORD, INTSUM vb., Aşama 6)
    istemcide DURMAYACAK; sunucu doğrulamasından sonra sunucudan istemciye gönderilecek.

    Parametreler:
        0: terminal <OBJECT>
        1: oyuncu birimi <OBJECT>

    Dönüş: yok
*/

params [["_terminal", objNull, [objNull]], ["_player", objNull, [objNull]]];

if (isNull _terminal) exitWith {};

[_terminal, _player] call TC2_fnc_uiOpen;
