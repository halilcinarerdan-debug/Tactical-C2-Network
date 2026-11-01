/*
    Fonksiyon: TC2_fnc_jtacSet
    Çalışma yeri: SADECE SUNUCU
                  - Zeus istemcisinden: remoteExecCall ["TC2_fnc_jtacSet", 2]
                  - sunucuda / Eden modülünden: doğrudan çağrı

    Bir askere JTAC yetkisi (`TC2_jtac`) verir ya da kaldırır. Değişken GLOBAL yazılır (JIP'e de iletilir).
    Sunucu doğrulaması: istek ağdan geliyorsa (remoteExecutedOwner != 0) gönderen oyuncunun bir Zeus (curator) olması gerekir;
    değilse reddedilir ve RPT'ye yazılır. Sonuç, istemciye bildirim olarak döner (jtacOnResult).

    Atama AÇIK yazılır (true/false): false, sınıf/rol açıklamasıyla JTAC sayılan askerin bile yetkisini kaldırır (bkz. isJtac).

    Not: yetki birime bağlıdır; birim ölüp yeniden doğunca (yeni birim) yetki gitmez -> Zeus tekrar atar.

    Parametreler:
        0: asker <OBJECT>
        1: JTAC olsun mu <BOOL>  (true = ata, false = kaldır)

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_state", true, [true]]];

private _sender = remoteExecutedOwner;
private _allowed = true;

if (_sender != 0) then {
    private _requester = (allPlayers select {owner _x == _sender}) param [0, objNull];
    _allowed = !isNull _requester && {!isNull (getAssignedCuratorLogic _requester)};
};

if (!_allowed) exitWith {
    diag_log format ["[TC2][JTAC] RED: gonderen=%1 Zeus degil (birim=%2)", _sender, if (isNull _unit) then {"yok"} else {name _unit}];
};

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {};

_unit setVariable ["TC2_jtac", _state, true];

diag_log format ["[TC2][JTAC] %1 | birim=%2 | gonderen=%3", if (_state) then {"ATANDI"} else {"KALDIRILDI"}, name _unit, _sender];

private _args = [name _unit, _state];
if (_sender != 0) then {
    _args remoteExecCall ["TC2_fnc_jtacOnResult", _sender];
} else {
    _args call TC2_fnc_jtacOnResult;
};
