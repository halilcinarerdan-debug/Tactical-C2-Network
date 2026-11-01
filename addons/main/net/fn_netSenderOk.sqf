/*
    Fonksiyon: TC2_fnc_netSenderOk
    Çalışma yeri: SADECE SUNUCU

    Gönderen doğrulama: remoteExecutedOwner, talepte adı geçen birimin sahibi olmalı. Başkası adına
    talep edilemez. remoteExecutedOwner = 0, ağdan gelmeyen yerel çağrıdır (host / tek oyunculu) ve güvenilir.

    Parametreler:
        0: talepte adı geçen birim <OBJECT>

    Dönüş: geçerli mi <BOOL>
*/

params [["_unit", objNull, [objNull]]];

private _sender = remoteExecutedOwner;
private _ok = (_sender == 0) || {!isNull _unit && {_sender == owner _unit}};

if (!_ok) then {
    diag_log format ["[TC2][NET] SENDER_MISMATCH birim=%1 sahip=%2 gonderen=%3", if (isNull _unit) then {"yok"} else {name _unit}, if (isNull _unit) then {-1} else {owner _unit}, _sender];
};

_ok
