/*
    Fonksiyon: TC2_fnc_debugVirtArty
    Çalışma yeri: SADECE SUNUCU (debug konsolunda host'ta "Local Exec", ayrılmış sunucuda "Server Exec")

    TEST YARDIMCISI: sanal topçu atışını CFF formunu doldurmadan, FDC / batarya seçmeden DOĞRUDAN tetikler. Hazır bir CFF görevi (sanal FDC'ye gitmiş gibi)
    yazar ve KABUL aşamasını (MTO, hedef numarası, atış) gerçek zincirle aynı kodla çalıştırır: MTO -> SHOT -> SPLASH -> mermiler düşer -> ROUNDS COMPLETE.
    CBA ayarı TC2_virt_arty KAPALI olsa da çalışır. Olay günlüğü satırları birimin açık tableti / terminalinde (TOPÇU sekmesi) ve RPT'de ("[TC2][TOPCU]") görünür.

    Parametreler:
        0: gözlemci birimi <OBJECT>     (varsayılan: player; ayrılmış sunucuda ilk oyuncu)
        1: hedef mesafesi <NUMBER>      birimin baktığı yönde, metre (varsayılan 500; HE'de 150 m'den yakın vurmayın)
        2: mühimmat <STRING>            "HE" | "SMOKE" | "WP" | "ILLUM" (varsayılan "HE")
        3: top başına mermi <NUMBER>    1-10 (varsayılan 2; toplam = bu x CBA sanal batarya top sayısı, varsayılan 4 -> 8 mermi)
        4: görev türü <STRING>          "FFE" | "ADJUST" (varsayılan "FFE"; ADJUST tek mermi)
        5: hazırlık gecikmesi <NUMBER>  saniye (varsayılan 5; normalde TC2_virt_artyPrep = 15). İlk mermi bundan sonra atılır, düşmesi için uçuş süresi
                                        (82 mm 18 sn, 120 mm 24 sn, 155 mm 32 sn) eklenir

    Dönüş: görev id <NUMBER>  (-1 = başlatılamadı; nedeni RPT'ye "[TC2][VIRT]" ile yazılır)

    Örnekler (host, Local Exec; ayrılmış sunucuda Server Exec ve oyuncu için allPlayers select 0 kullanılır):
        [] call TC2_fnc_debugVirtArty;                                   // 500 m önünüze, HE, FFE
        [player, 700, "SMOKE", 1] call TC2_fnc_debugVirtArty;           // duman perdesi
        [player, 600, "ILLUM", 1] call TC2_fnc_debugVirtArty;           // aydınlatma
        [player, 600, "HE", 1, "ADJUST"] call TC2_fnc_debugVirtArty;    // tek mermi (adjust fire)
*/

if (!isServer) exitWith {-1};

params [
    ["_unit", objNull, [objNull]], ["_distance", 500, [0]], ["_projectile", "HE", [""]], ["_volume", 2, [0]],
    ["_type", "FFE", [""]], ["_prep", 5, [0]]
];

if (isNull _unit) then {
    _unit = if (!isNull player) then {player} else {if (count allPlayers > 0) then {allPlayers select 0} else {objNull}};
};
if (isNull _unit) exitWith {
    diag_log "[TC2][VIRT] debugVirtArty: birim yok (ayrilmis sunucuda [allPlayers select 0, ...] verin).";
    -1
};

if !(_projectile in ["HE", "SMOKE", "WP", "ILLUM"]) then {_projectile = "HE"};
if !(_type in ["FFE", "ADJUST"]) then {_type = "FFE"};
_volume = (round _volume) max 1 min 10;

private _say = {
    params ["_unit", "_text", "_type"];
    diag_log format ["[TC2][VIRT] debugVirtArty: %1", _text];
    if (local _unit) then {[_text, _type] call TC2_fnc_notify};
};

private _shellClass = [_projectile] call TC2_fnc_virtShellClass;
if (_shellClass isEqualTo "") exitWith {
    [_unit, format ["%1 için mermi sınıfı bulunamadı (mod / harita kalibresi). Başka mühimmat deneyin.", _projectile], "error"] call _say;
    -1
};

private _dir = getDir _unit;
private _targetAGL = _unit getPos [_distance max 50, _dir];
private _position = ATLToASL [_targetAGL select 0, _targetAGL select 1, 0];
_position set [2, getTerrainHeightASL [_position select 0, _position select 1]];

// CFF verisi (15 eleman, bkz. artyValidate): GRID yöntemi, açık arazide piyade
private _data = [
    _type, "GRID", _position, [], [], "debug hedefi (piyade, acikta)", "OPEN", "AREA", false, false,
    "LOW", _projectile, _volume, "FWR", [0, 30] select (_projectile isEqualTo "SMOKE")
];

// Gözlemcinin eski etkin görevini iptal et (gerçek zincirdeki tek etkin görev kuralı)
private _observerNet = netId _unit;
private _missions = missionNamespace getVariable ["TC2_arty_missions", []];
{
    if ((_x select 1) isEqualTo _observerNet && {!((_x select 7) in ["EOM", "REJECTED", "CANCELLED"])}) then {
        _x set [7, "CANCELLED"];
    };
} forEach _missions;

private _id = (missionNamespace getVariable ["TC2_arty_nextId", 0]) + 1;
missionNamespace setVariable ["TC2_arty_nextId", _id];
missionNamespace setVariable [format ["TC2_virt_prep_%1", _id], _prep max 0];

private _callsign = [groupId (group _unit), 24] call TC2_fnc_netSanitize;
private _direction = (round (([_unit getDir _position, "TOMIL"] call TC2_fnc_artyMilsToDeg) / 10) * 10) mod 6400;
private _phase = ["FFE", "ADJUST"] select (_type isEqualTo "ADJUST");

_missions pushBack [
    _id, _observerNet, _unit, _callsign, "VIRT_FDC", objNull, "SANAL FDC (yapay)", "REQUEST", _data, "", _position, _direction,
    [], _volume, [], diag_tickTime, ["ACRE_PRC343", _unit] call TC2_fnc_netBaseKey, 1, 0, _phase, 0, false, false, "", "", ""
];
missionNamespace setVariable ["TC2_arty_missions", _missions];

[_unit, format ["Sanal topçu tetiklendi: görev #%1, %2 %3, %4 m önde (grid %5), top başına %6 mermi, hazırlık %7 sn.", _id, _type, _projectile, round _distance, [_position] call TC2_fnc_casGrid, _volume, round _prep], "info"] call _say;
[_id, format ["CFF #%1  %2  DEBUG  (sanal FDC'ye gitti)", _id, _callsign], "INFO", "BOTH"] call TC2_fnc_artyEvent;

private _targetNo = [_id, 0, "", "DEBUG"] call TC2_fnc_virtArtyAccept;
if (_targetNo isEqualTo "") exitWith {
    [_unit, "Sanal batarya görevi kabul edemedi (ayrıntı RPT: [TC2][TOPCU])", "error"] call _say;
    -1
};

_id
