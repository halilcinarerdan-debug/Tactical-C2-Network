/*
    Fonksiyon: TC2_fnc_virtCasTick
    Çalışma yeri: SADECE SUNUCU (virtCasRun'ın CBA PerFrameHandler'ı, 0.1 sn)

    Sanal CAS uçuş ve silah durumu makinesi:
      APPROACH  atak yönünde sabit irtifada, hedefe ~3 km kala ATTACK
      ATTACK    uçak doğrudan hedefe uçar (burun hedefe), mesafeye göre silah ateşler:
                  füze  4000-3000 m (1 kez)    roket  2600-1800 m (0.25 sn'de bir, en çok 8)
                  top   2000-850 m (her tik)   bomba  1300-1000 m (1 kez, 2. için 0.8 sn sonra; en çok 2)
                500 m ya da yer üstü 60 m altında EGRESS
      EGRESS    tırmanışla uzaklaşır; 35 sn sonra uçak ve mürettebat silinir, sortie biter
    Talep iptal edilirse (ABORTED) ATTACK'ten önce doğrudan EGRESS. Mesajlar JTAC'ın ağına gider (IN HOT, RIFLE, GUNS GUNS, OFF TARGET).

    Parametreler: PFH standardı [[args], handle]
    Dönüş: yok
*/

if (!isServer) exitWith {};

params ["_pfh", "_handle"];
_pfh params ["_id", "_plane", "_targetObject", "_aim", "_dirH", "_weapons", "_vehicleTarget", "_phase", "_phaseStart", "_counters", "_sideKey", "_flags"];
_weapons params ["_gun", "_rocket", "_bomb", "_missile"];

private _index = [_id] call TC2_fnc_casReqIndex;
private _request = if (_index >= 0) then {(missionNamespace getVariable ["TC2_cas_requests", []]) select _index} else {[]};
private _jtacNet = if (_request isEqualTo []) then {""} else {_request select 1};
private _aborted = _request isEqualTo [] || {(_request select 7) isEqualTo "ABORTED"};

private _speed = 200;
private _now = diag_tickTime;
private _say = {
    params ["_key", "_text"];
    if !(_key in _flags) then {
        _flags pushBack _key;
        if !(_jtacNet isEqualTo "") then {[_jtacNet, _text] call TC2_fnc_netInfo};
    };
};

private _cleanup = {
    [_handle] call CBA_fnc_removePerFrameHandler;
    {deleteVehicle _x} forEach (crew _plane);
    deleteVehicle _plane;
    deleteVehicle _targetObject;
    missionNamespace setVariable [format ["TC2_virt_casBusy_%1", _sideKey], false];
    missionNamespace setVariable [format ["TC2_virt_casReady_%1", _sideKey], diag_tickTime + (missionNamespace getVariable ["TC2_virt_casCooldown", 120])];
};

if (isNull _plane || {!alive _plane}) exitWith {call _cleanup};

private _position = getPosASL _plane;

switch (_phase) do {
    case "APPROACH": {
        if (_aborted) exitWith {
            _pfh set [7, "EGRESS"]; _pfh set [8, _now];
            ["abort", format ["SANAL CAS #%1: ABORT, uçak ayrılıyor.", _id]] call _say;
        };
        private _along = ((_position select 0) - (_aim select 0)) * (_dirH select 0) + ((_position select 1) - (_aim select 1)) * (_dirH select 1);     // negatif: hedefin gerisinde
        private _cruise = (_aim select 2) + 800;
        private _vz = (((_cruise - (_position select 2)) * 0.6) max -20) min 20;
        _plane setVelocity [(_dirH select 0) * _speed, (_dirH select 1) * _speed, _vz];
        _plane setVectorDirAndUp [_dirH, [0, 0, 1]];
        if (_along > -3000) then {
            _pfh set [7, "ATTACK"]; _pfh set [8, _now];
            ["hot", format ["SANAL CAS #%1: IN HOT.", _id]] call _say;
        };
    };

    case "ATTACK": {
        if (_aborted) exitWith {
            _pfh set [7, "EGRESS"]; _pfh set [8, _now];
            ["abort", format ["SANAL CAS #%1: ABORT, uçak ayrılıyor.", _id]] call _say;
        };

        private _toTarget = _aim vectorDiff _position;
        private _range = vectorMagnitude _toTarget;
        private _direction = _toTarget vectorMultiply (1 / (_range max 1));
        _plane setVectorDirAndUp [_direction, [0, 0, 1]];
        _plane setVelocity (_direction vectorMultiply _speed);

        private _driver = driver _plane;
        _driver doTarget _targetObject;
        _plane reveal [_targetObject, 4];

        private _fire = {
            params ["_weapon"];
            if !(_weapon isEqualTo "") then {_plane fireAtTarget [_targetObject, _weapon]};
        };

        // sıra: araç hedefinde füze/bomba öncelikli
        if (_range < 4000 && {_range > 3000} && {_vehicleTarget} && {(_counters select 3) < 1}) then {
            _counters set [3, 1];
            [_missile] call _fire;
            ["rifle", format ["SANAL CAS #%1: RIFLE (füze).", _id]] call _say;
        };
        if (_range < 2600 && {_range > 1800} && {(_counters select 1) < 8} && {(_now - (_counters select 4)) >= 0.25}) then {
            _counters set [1, (_counters select 1) + 1];
            _counters set [4, _now];
            [_rocket] call _fire;
            if !(_rocket isEqualTo "") then {["rockets", format ["SANAL CAS #%1: RIFLE (roket).", _id]] call _say};
        };
        if (_range < 2000 && {_range > 850}) then {
            [_gun] call _fire;
            if !(_gun isEqualTo "") then {["guns", format ["SANAL CAS #%1: GUNS GUNS GUNS.", _id]] call _say};
        };
        if (_range < 1300 && {_range > 1000} && {(_counters select 2) < 2} && {(_vehicleTarget || {_gun isEqualTo ""})}) then {
            if ((_now - (_counters select 4)) >= 0.8) then {
                _counters set [2, (_counters select 2) + 1];
                _counters set [4, _now];
                [_bomb] call _fire;
                if !(_bomb isEqualTo "") then {["bomb", format ["SANAL CAS #%1: RIFLE (bomba).", _id]] call _say};
            };
        };

        if (_range < 500 || {(_position select 2) < ((_aim select 2) + 60)}) then {
            _pfh set [7, "EGRESS"]; _pfh set [8, _now];
            ["off", format ["SANAL CAS #%1: OFF TARGET, çıkış.", _id]] call _say;
        };
    };

    case "EGRESS": {
        private _climb = _dirH vectorMultiply _speed;
        _plane setVelocity [_climb select 0, _climb select 1, 45];
        _plane setVectorDirAndUp [[(_dirH select 0) * 0.96, (_dirH select 1) * 0.96, 0.28], [0, 0, 1]];
        if ((_now - _phaseStart) > 35) then {
            ["done", format ["SANAL CAS #%1: sortie tamam, yeniden silahlanıyor.", _id]] call _say;
            call _cleanup;
        };
    };
};
