/*
    Fonksiyon: TC2_fnc_debugVirtCas
    Çalışma yeri: SADECE SUNUCU (debug konsolunda host'ta "Local Exec", ayrılmış sunucuda "Server Exec")

    TEST YARDIMCISI: sanal CAS sortisini 9-Line formunu doldurmadan DOĞRUDAN tetikler. Normal zincirin son halkasını (formun doğru geri okunması,
    "READBACK_OK") hazır bir talep olarak yazar ve virtCasStart'ı çağırır; uçak, silahlar, ABORT, bekleme süresi gerçek zincirle aynı kodu çalıştırır.
    CBA ayarı TC2_virt_cas KAPALI olsa da çalışır (yalnızca sanal CAS'ın meşgul / bekleme denetimi uygulanır).

    Parametreler:
        0: JTAC birimi <OBJECT>         (varsayılan: player; ayrılmış sunucuda ilk oyuncu)
        1: hedef mesafesi <NUMBER>      birimin baktığı yönde, metre (varsayılan 600)
        2: saldırı yönü <NUMBER>        derece 0-359 (varsayılan -1 = birimin baktığı yönün 90° sağı; uçak oyuncunun üstünden değil yanından geçer)
        3: hedef tanımı <STRING>        (varsayılan "piyade"; "BMP zirhli arac" yazarsanız araç hedefi olur: füze -> bomba -> roket -> top)
        4: işaret <STRING>              "NONE" | "SMOKE" | "LASER" | "IR" (varsayılan "NONE")
        5: uçağın gelme gecikmesi <NUMBER> saniye (varsayılan 8; normalde TC2_virt_casDelay = 45)

    Dönüş: talep id <NUMBER>  (-1 = başlatılamadı; nedeni RPT'ye "[TC2][VIRT]" ile yazılır)

    Örnekler (host, Local Exec; ayrılmış sunucuda Server Exec ve oyuncu için allPlayers select 0 kullanılır):
        [] call TC2_fnc_debugVirtCas;                                              // 600 m önünüze, piyade hedef
        [player, 800, 0, "BMP zirhli arac"] call TC2_fnc_debugVirtCas;             // araç hedefi: kuzeyden atak (füze + bomba + roket + top)
        [player, 500, -1, "piyade", "LASER"] call TC2_fnc_debugVirtCas;            // lazer işaretli hedef
*/

if (!isServer) exitWith {-1};

params [
    ["_unit", objNull, [objNull]], ["_distance", 600, [0]], ["_heading", -1, [0]], ["_description", "piyade", [""]],
    ["_mark", "NONE", [""]], ["_delay", 8, [0]]
];

if (isNull _unit) then {
    _unit = if (!isNull player) then {player} else {if (count allPlayers > 0) then {allPlayers select 0} else {objNull}};
};
if (isNull _unit) exitWith {
    diag_log "[TC2][VIRT] debugVirtCas: birim yok (ayrilmis sunucuda [allPlayers select 0, ...] verin).";
    -1
};

private _say = {
    params ["_unit", "_text", "_type"];
    diag_log format ["[TC2][VIRT] debugVirtCas: %1", _text];
    if (local _unit) then {[_text, _type] call TC2_fnc_notify};
    [netId _unit, _text] call TC2_fnc_netInfo;
};

private _side = side (group _unit);
private _sideKey = str _side;

if (missionNamespace getVariable [format ["TC2_virt_casBusy_%1", _sideKey], false]) exitWith {
    [_unit, format ["Sanal CAS zaten sortide (meşgul). Bitmesini bekleyin ya da sıfırlayın: missionNamespace setVariable ['TC2_virt_casBusy_%1', false]", _sideKey], "error"] call _say;
    -1
};

if !(_mark in ["NONE", "SMOKE", "LASER", "IR"]) then {_mark = "NONE"};
_description = [_description, 100] call TC2_fnc_netSanitize;

private _dir = getDir _unit;
if (_heading < 0) then {_heading = (_dir + 90) mod 360};
_heading = round (_heading mod 360);

private _targetAGL = _unit getPos [_distance max 50, _dir];
private _targetPos = ATLToASL [_targetAGL select 0, _targetAGL select 1, 0];
private _elevationFt = round ((getTerrainHeightASL [_targetPos select 0, _targetPos select 1]) * 3.281);

// 9-Line verisi (19 eleman, bkz. casValidate): sanal pilot zaten geri okumuş gibi, form doğru
private _data = [
    1, "BOT", "TEST-IP", _heading, "", 7.0, _elevationFt, _description, _targetPos,
    _mark, ["", "1688"] select (_mark isEqualTo "LASER"), -1, "", "N", "DEBUG", _heading, "", "", ""
];

private _jtacNet = netId _unit;
private _id = (missionNamespace getVariable ["TC2_cas_nextId", 0]) + 1;
missionNamespace setVariable ["TC2_cas_nextId", _id];

private _requests = missionNamespace getVariable ["TC2_cas_requests", []];
private _callsign = [groupId (group _unit), 24] call TC2_fnc_netSanitize;
_requests pushBack [
    _id, _jtacNet, _unit, "VIRT_CAS", objNull, _data, "FW", "READBACK_OK", [], diag_tickTime,
    ["ACRE_PRC343", _unit] call TC2_fnc_netBaseKey, 1, _callsign, "SANAL CAS", true, false
];
missionNamespace setVariable ["TC2_cas_requests", _requests];

[_unit, format ["Sanal CAS tetiklendi: #%1, hedef %2 m önde (grid %3), atak yönü %4°, işaret %5, uçak ~%6 sn sonra.", _id, round _distance, [_targetPos] call TC2_fnc_casGrid, _heading, _mark, round _delay], "info"] call _say;

[_id, _delay max 0] call TC2_fnc_virtCasStart;

_id
