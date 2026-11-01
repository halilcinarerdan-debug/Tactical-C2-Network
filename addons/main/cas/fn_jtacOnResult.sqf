/*
    Fonksiyon: TC2_fnc_jtacOnResult
    Çalışma yeri: İSTEMCİ (Zeus; sunucu jtacSet sonucunu gönderir)

    Zeus'a JTAC atama/kaldırma sonucunu bildirir.

    Parametreler:
        0: birim adı <STRING>
        1: JTAC mı <BOOL>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_name", "", [""]], ["_state", true, [true]]];

[format ["%1: %2", _name, ["JTAC yetkisi KALDIRILDI.", "JTAC olarak ATANDI."] select _state], ["info", "success"] select _state] call TC2_fnc_notify;
