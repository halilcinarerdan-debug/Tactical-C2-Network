/*
    Fonksiyon: TC2_fnc_accessResult
    Çalışma yeri: İSTEMCİ (sunucu remoteExecCall ile talep eden oyuncunun makinesine gönderir;
                  host / tek oyunculuda doğrudan çağrılır)

    Sunucunun erişim kararını uygular:
      onay -> terminalOpen,   ret -> sebebe göre Türkçe hata mesajı.

    Talep numarası (reqId) bekleyen talepten farklıysa (eski yanıt, zaman aşımından sonra gelen yanıt)
    yok sayılır.

    Parametreler:
        0: terminal <OBJECT>
        1: izin verildi mi <BOOL>
        2: neden kodu <STRING>
        3: talep numarası <NUMBER>

    Dönüş: yok
*/

// Dedicated sunucuda (arayüz yok) yerel AI birimi için gelen çağrıyı yut.
if (!hasInterface) exitWith {};

params [["_terminal", objNull, [objNull]], ["_granted", false, [false]], ["_reason", "UNKNOWN", [""]], ["_reqId", -1, [0]]];

if (_reqId != (missionNamespace getVariable ["TC2_access_pendingId", -1])) exitWith {};

missionNamespace setVariable ["TC2_access_pendingId", -1];

if (_granted) then {
    [_terminal, ACE_player] call TC2_fnc_terminalOpen;
} else {
    [[_reason] call TC2_fnc_accessReasonText, "error"] call TC2_fnc_notify;
};
