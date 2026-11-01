/*
    Fonksiyon: TC2_fnc_artyObsAction
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_artyObsAction", 2]
                  - host / tek oyunculuda: artyUiObsAction doğrudan çağırır

    Gözlemcinin görev sırasındaki işlemleri (ATP 3-09.30, bölüm 5). Doğrulamalar: gönderen, oturum, gözlemci/JTAC yetkisi, görev bu gözlemciye ait.
      CORRECT  [yön mil (-1 = aynı), sol/sağ m (+sağ), add/drop m (+add), up/down m, yeni görev ("" | "ADJUST" | "FFE"), danger close (0 aynı | 1 var | 2 yok)]
               Yalnızca SPOTTING / SURVEILLANCE durumunda. Düzeltme nişan noktasına OT hattına göre uygulanır (artyCorrect).
               Kurallar: DANGER CLOSE gerekliyse (dost <= 600 m) bildirilmeden kabul edilmez; danger close'ta menzil düzeltmesi
               en çok 100 m (creeping fire); 30 m'den küçük sapma düzeltmesi "minör"dür (uyarı satırı, uygulanır).
               AT MY COMMAND ise "<batarya> IS READY", değilse atış hemen.
      REPEAT   düzeltmesiz tekrar (ADJUST: aynı veri ile bir mermi daha; FFE: aynı hacim).
      FIRE     AT MY COMMAND'da (READY) atışı başlatır.
      CHECK    CHECK FIRING.
      EOM      [gözetim metni, RECORD AS TARGET (bool)]  END OF MISSION; kayıt istenirse hedef numarası + konum saklanır (sonraki SHIFT'ler için).

    Parametreler:
        0: gözlemci birimi <OBJECT>
        1: terminal / saha cihazı <OBJECT>
        2: telsiz durumu <ARRAY>
        3: işlem <STRING>
        4: görev id <NUMBER>
        5: argümanlar <ARRAY>

    Dönüş: yok (yanıt: artyOnAck ve artyOnEvent)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_action", "", [""]], ["_id", -1, [0]], ["_args", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code"];

if (!_ok || {!(_code isEqualTo "OK")}) exitWith {
    [_unit, "TC2_fnc_artyOnAck", [_code, []]] call TC2_fnc_netToUnit;
};

if !([_unit, _terminal, "ARTY"] call TC2_fnc_canWriteFires) exitWith {
    [_unit, "TC2_fnc_artyOnAck", ["NOT_OBSERVER", []]] call TC2_fnc_netToUnit;
};

private _index = [_id] call TC2_fnc_artyMissionIndex;
if (_index < 0) exitWith {
    [_unit, "TC2_fnc_artyOnAck", ["NOT_FOUND", []]] call TC2_fnc_netToUnit;
};

private _mission = (missionNamespace getVariable ["TC2_arty_missions", []]) select _index;
if !((_mission select 1) isEqualTo (netId _unit)) exitWith {
    diag_log format ["[TC2][TOPCU] RED gorev baska gozlemciye ait id=%1 birim=%2", _id, name _unit];
};

private _status = _mission select 7;
private _ack = {[_unit, "TC2_fnc_artyOnAck", _this] call TC2_fnc_netToUnit};

// Düzeltme ya da tekrar: ortak kısım
private _applyCorrection = {
    params ["_dir", "_right", "_add", "_up", "_newType", "_dcMode"];

    if (_dir >= 0) then {
        if (_dir > 6399) exitWith {};
        _mission set [11, _dir];
    };

    private _aim = [_mission select 10, _mission select 11, _right, _add, _up] call TC2_fnc_artyCorrect;
    private _dangerClose = switch (_dcMode) do {
        case 1: {true};
        case 2: {false};
        default {_mission select 22};
    };

    private _near = [_aim, side (group _unit)] call TC2_fnc_artyNearestFriendly;
    if ((_near select 0) <= 600 && {!_dangerClose}) exitWith {
        ["DANGER_CLOSE", [round (_near select 0), _near select 1]] call _ack;
        false
    };
    if (_dangerClose && {abs _add > 100}) exitWith {
        ["CREEP", []] call _ack;
        false
    };

    _mission set [10, _aim];
    _mission set [22, _dangerClose];
    if !(_newType isEqualTo "") then {_mission set [19, _newType]};

    private _parts = [];
    if (_dir >= 0) then {_parts pushBack format ["DIRECTION %1", _dir]};
    if (_dangerClose) then {_parts pushBack "DANGER CLOSE"};
    if (_right != 0) then {_parts pushBack format ["%1 %2", ["RIGHT", "LEFT"] select (_right < 0), abs _right]};
    if (_add != 0) then {_parts pushBack format ["%1 %2", ["ADD", "DROP"] select (_add < 0), abs _add]};
    if (_up != 0) then {_parts pushBack format ["%1 %2", ["UP", "DOWN"] select (_up < 0), abs _up]};
    if !(_newType isEqualTo "") then {_parts pushBack (["ADJUST FIRE", "FIRE FOR EFFECT"] select (_newType isEqualTo "FFE"))};
    if (_parts isEqualTo []) then {_parts pushBack "REPEAT"};

    [_id, (_parts joinString ", ") + ", OVER.", "INFO", "BOTH"] call TC2_fnc_artyEvent;

    if ((abs _right) > 0 && {(abs _right) < 30}) then {
        [_id, "Not: 30 m'den küçük sapma düzeltmesi 'minör'dür; doktrinde gönderilmez (rafine/hassas atış hariç).", "INFO", "OBS"] call TC2_fnc_artyEvent;
    };

    if (((_mission select 8) select 13) isEqualTo "AMC") then {
        _mission set [7, "READY"];
        [_id, format ["%1 IS READY, OVER.", _mission select 23], "GOOD"] call TC2_fnc_artyEvent;
    } else {
        [_id] call TC2_fnc_artyExecute;
    };
    true
};

switch (_action) do {
    case "CORRECT": {
        if !(_status in ["SPOTTING", "SURVEILLANCE"]) exitWith {["BAD_STATE", []] call _ack};
        _args params [["_dir", -1, [0]], ["_right", 0, [0]], ["_add", 0, [0]], ["_up", 0, [0]], ["_newType", "", [""]], ["_dcMode", 0, [0]]];
        if !(_newType in ["", "ADJUST", "FFE"]) exitWith {};
        [_dir, _right, _add, _up, _newType, _dcMode] call _applyCorrection;
    };

    case "REPEAT": {
        if !(_status in ["SPOTTING", "SURVEILLANCE"]) exitWith {["BAD_STATE", []] call _ack};
        [-1, 0, 0, 0, "", 0] call _applyCorrection;
    };

    case "FIRE": {
        if !(_status isEqualTo "READY") exitWith {["BAD_STATE", []] call _ack};
        [_id, "FIRE, OUT.", "INFO"] call TC2_fnc_artyEvent;
        [_id] call TC2_fnc_artyExecute;
    };

    case "CHECK": {
        if !(_status in ["FIRING", "READY"]) exitWith {["BAD_STATE", []] call _ack};
        [_id, "CHECK"] call TC2_fnc_artyComplete;
    };

    case "EOM": {
        if !(_status in ["SPOTTING", "SURVEILLANCE", "READY", "FIRING"]) exitWith {["BAD_STATE", []] call _ack};
        _args params [["_text", "", [""]], ["_record", false, [false]]];
        private _surveillance = [_text, 60] call TC2_fnc_netSanitize;

        if (_status in ["FIRING", "READY"]) then {[_id, "CHECK"] call TC2_fnc_artyComplete};

        if (_record && {!((_mission select 9) isEqualTo "")}) then {
            private _targets = missionNamespace getVariable ["TC2_arty_targets", []];
            _targets pushBack [_mission select 9, _mission select 10];
            missionNamespace setVariable ["TC2_arty_targets", _targets];
        };

        _mission set [7, "EOM"];
        [_id, format ["%1END OF MISSION, %2, OVER.", ["", "RECORD AS TARGET, "] select _record, ["HEDEF DURUMU BELİRTİLMEDİ", _surveillance] select !(_surveillance isEqualTo "")], "GOOD"] call TC2_fnc_artyEvent;
        [_id, "Görev sona erdi.", "INFO", "FDC"] call TC2_fnc_artyEvent;
        diag_log format ["[TC2][TOPCU] EOM id=%1 | gozlemci=%2 | kayit=%3 | %4", _id, name _unit, _record, _surveillance];
        ["EOM", []] call _ack;
    };

    default {};
};
