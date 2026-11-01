/*
    Fonksiyon: TC2_fnc_accessServerHandle
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_accessServerHandle", 2]
                  - host / tek oyunculuda: accessRequest doğrudan çağırır

    Erişim talebinin SUNUCU TARAFI. Yetki kararını burada, sunucunun kendi verisiyle verir:

      1. Gönderen doğrulama: remoteExecutedOwner, talepte adı geçen birimin sahibi olmalı.
         Bir istemci başkası adına talep gönderemez (SENDER_MISMATCH). remoteExecutedOwner = 0,
         "ağdan gelmeyen yerel çağrı" demektir (host / tek oyunculu) ve güvenilirdir.
      2. TC2_fnc_accessCheck ile karar.
      3. Denetim kaydı (RPT): kim, hangi terminal, sonuç, neden. OPSEC için tüm denemeler kaydedilir.
      4. Sonucu talep eden istemciye gönder (sahte talebe yanıt verilmez).

    Parametreler:
        0: terminal <OBJECT>
        1: talep eden birim <OBJECT>
        2: talep numarası <NUMBER>  (yanıtta aynen geri döner)

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_terminal", objNull, [objNull]], ["_unit", objNull, [objNull]], ["_reqId", -1, [0]]];

private _sender = remoteExecutedOwner;
private _spoofed = (_sender != 0) && {isNull _unit || {_sender != owner _unit}};

private _result = if (_spoofed) then {
    [false, "SENDER_MISMATCH"]
} else {
    [_terminal, _unit] call TC2_fnc_accessCheck
};
_result params ["_granted", "_reason"];

// Denetim kaydı. Sunucu RPT'sinde "[TC2][ACCESS]" ile aranır.
private _distance = if (isNull _terminal || {isNull _unit}) then {-1} else {(round ((_unit distance _terminal) * 10)) / 10};
diag_log format [
    "[TC2][ACCESS] %1 | neden=%2 | terminal=%3 | birim=%4 | uid=%5 | sahip=%6 | gonderen=%7 | mesafe=%8m",
    if (_granted) then {"ONAY"} else {"RED"},
    _reason,
    [_terminal] call TC2_fnc_terminalGetId,
    if (isNull _unit) then {"yok"} else {name _unit},
    if (isNull _unit) then {""} else {getPlayerUID _unit},
    if (isNull _unit) then {-1} else {owner _unit},
    _sender,
    _distance
];

// Sahte talebe ya da geçersiz birime yanıt verilmez.
if (_spoofed || {isNull _unit}) exitWith {};

if (local _unit) then {
    // Birim sunucuda yerel (host oyuncusu, tek oyunculu veya AI): ağa gerek yok.
    [_terminal, _granted, _reason, _reqId] call TC2_fnc_accessResult;
} else {
    // Uzak oyuncu: yanıtı yalnızca o makineye gönder.
    [_terminal, _granted, _reason, _reqId] remoteExecCall ["TC2_fnc_accessResult", owner _unit];
};
