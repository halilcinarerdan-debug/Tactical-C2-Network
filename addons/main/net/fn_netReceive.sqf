/*
    Fonksiyon: TC2_fnc_netReceive
    Çalışma yeri: İSTEMCİ (sunucu, menzildeki eşlere gönderir)

    Gelen mesajı işler:
      MSG  -> günlüğe yazar + bildirim
      PING -> günlüğe yazar + otomatik PONG ile yanıtlar
      PONG -> günlüğe yazar (kimden, kaç metre)
      INFO -> üs bilgisi: günlüğe düşer (bildirim yok); sahadan gönderilen formları üs terminali de görür
    PONG'a yanıt verilmez (döngü olmaz).

    Parametreler:
        0: tür <STRING>
        1: gönderen etiketi <STRING>   "Ad / terminal"
        2: metin <STRING>
        3: mesafe, metre <NUMBER>
        4: gönderen netId <STRING>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_type", "MSG", [""]], ["_from", "?", [""]], ["_text", "", [""]], ["_distance", 0, [0]], ["_fromNetId", "", [""]]];

switch (_type) do {
    case "MSG": {
        [format ["%1 (%2 m): %3", _from, _distance, _text], "#40ff59"] call TC2_fnc_netLog;
        [format ["Yeni mesaj: %1", _from], "info"] call TC2_fnc_notify;
    };
    case "PING": {
        [format ["PING alındı: %1 (%2 m)", _from, _distance], "#1f9930"] call TC2_fnc_netLog;
        ["PONG", "", _fromNetId] call TC2_fnc_netSend;
    };
    case "INFO": {
        [_text, "#7fb0ff"] call TC2_fnc_netLog;
    };
    case "PONG": {
        [format ["PONG: %1 (%2 m)", _from, _distance], "#40ff59"] call TC2_fnc_netLog;
    };
};
