/*
    Fonksiyon: TC2_fnc_terminalOpen
    Çalışma yeri: İstemci (sunucu erişimi ONAYLADIKTAN sonra accessResult çağırır)

    AŞAMA 1: Yer tutucu. Onay bildirimi gösterir ve yerel bir CBA olayı yayınlar.
    AŞAMA 2'de bu fonksiyonun gövdesi terminal arayüzünü (RscDisplay) açacak; çağıran kod değişmeyecek.

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

private _id = [_terminal] call TC2_fnc_terminalGetId;

missionNamespace setVariable ["TC2_terminal_current", _terminal];

[format ["ERİŞİM ONAYLANDI. Terminal: %1. (Arayüz Aşama 2'de eklenecek.)", _id], "success"] call TC2_fnc_notify;

// Aşama 2 ve sonrası bu olaya bağlanabilir.
["TC2_terminalOpened", [_terminal, _player]] call CBA_fnc_localEvent;
