/*
    Fonksiyon: TC2_fnc_roleSet
    Çalışma yeri: SADECE SUNUCU
                  - Zeus istemcisinden: remoteExecCall ["TC2_fnc_roleSet", 2]
                  - sunucuda / Eden modülünden: doğrudan çağrı

    Bir askere rol verir ya da kaldırır: JTAC (`TC2_jtac`), gözlemci (`TC2_observer`), FDC operatörü (`TC2_fdc`).
    Değişken GLOBAL yazılır (JIP'e de iletilir). Açık yazılır (true/false): false, sınıf/rol açıklamasıyla o role
    sayılan askerin bile yetkisini kaldırır (bkz. hasRole).
    Sunucu doğrulaması: istek ağdan geliyorsa (remoteExecutedOwner != 0) gönderen oyuncunun bir Zeus (curator) olması gerekir;
    değilse reddedilir ve RPT'ye yazılır. Sonuç, istemciye bildirim olarak döner (roleOnResult).

    Not: yetki birime bağlıdır; birim ölüp yeniden doğunca (yeni birim) yetki gitmez -> Zeus tekrar atar.

    Parametreler:
        0: asker <OBJECT>
        1: rol <STRING>   "JTAC" | "OBSERVER" | "FDC"
        2: olsun mu <BOOL>  (true = ata, false = kaldır)

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_role", "", [""]], ["_state", true, [true]]];

private _variable = switch (toUpper _role) do {
    case "JTAC":     {"TC2_jtac"};
    case "OBSERVER": {"TC2_observer"};
    case "FDC":      {"TC2_fdc"};
    default {""};
};
if (_variable isEqualTo "") exitWith {};

private _sender = remoteExecutedOwner;
private _allowed = true;

if (_sender != 0) then {
    private _requester = (allPlayers select {owner _x == _sender}) param [0, objNull];
    _allowed = !isNull _requester && {!isNull (getAssignedCuratorLogic _requester)};
};

if (!_allowed) exitWith {
    diag_log format ["[TC2][ROL] RED: gonderen=%1 Zeus degil (birim=%2, rol=%3)", _sender, if (isNull _unit) then {"yok"} else {name _unit}, _role];
};

if (isNull _unit || {!(_unit isKindOf "CAManBase")}) exitWith {};

_unit setVariable [_variable, _state, true];

diag_log format ["[TC2][ROL] %1 %2 | birim=%3 | gonderen=%4", toUpper _role, if (_state) then {"ATANDI"} else {"KALDIRILDI"}, name _unit, _sender];

private _args = [name _unit, toUpper _role, _state];
if (_sender != 0) then {
    _args remoteExecCall ["TC2_fnc_roleOnResult", _sender];
} else {
    _args call TC2_fnc_roleOnResult;
};
