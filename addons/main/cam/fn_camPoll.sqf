/*
    Fonksiyon: TC2_fnc_camPoll
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_camPoll", 2]
                  - host / tek oyunculuda: camUiRequest doğrudan çağırır

    KAMERA sekmesinin kaynak listesi: izlenebilir İHA'lar ve kask kameraları. YALNIZCA İZLEME: kontrol yok, hiçbir İHA'ya bağlanılmaz.
    Yetki: oturum geçerli (kart; telsiz yalnızca CBA TC2_cam_requireRadio açıksa şart) + Level 2 ve üstü + izleme modunda değil (bilgi güvenirliği: er tabletle kamera izleyemez).
      İHA:  aynı taraf, canlı, `unitIsUAV`, CBA TC2_cam_uavShare açık, objede TC2_camHidden yok.
      Kask: aynı taraf, canlı, oyuncu / AI fark etmez, envanterinde CBA kask eşyası (TC2_cam_helmetItem) var; CBA açıksa izleyenin telsiz menzili içinde.
    Yanıt: kod, seviye, izleyebilir mi, kaynaklar [[tür "UAV" | "HELM", netId, etiket]], kullanım modu (DESK | FIELD | VIEW).

    Parametreler:
        0: birim <OBJECT>   1: terminal / saha cihazı <OBJECT>   2: telsiz durumu <ARRAY>

    Dönüş: yok (yanıt: camOnData)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code", "_entry"];

// Telsiz şartı: CBA TC2_cam_requireRadio kapalıysa (varsayılan) İHA veri bağı / kask ağı telsizden bağımsız sayılır; telsiz yoksa da izlenebilir.
private _radioOptional = !(missionNamespace getVariable ["TC2_cam_requireRadio", false]);
if (!_ok || {!(_code isEqualTo "OK" || {_radioOptional && {_code in ["NO_RADIO", "NO_ACRE"]}})}) exitWith {
    [_unit, "TC2_fnc_camOnData", [_code, 1, false, [], ""]] call TC2_fnc_netToUnit;
};

private _level = [_unit, _terminal] call TC2_fnc_accessLevel;
private _mode = _entry param [9, "DESK"];
private _canView = _level >= 2 && {!(_mode isEqualTo "VIEW")};

if (!_canView) exitWith {
    diag_log format ["[TC2][KAMERA] RED: %1 | seviye=%2 mod=%3", name _unit, _level, _mode];
    [_unit, "TC2_fnc_camOnData", ["OK", _level, false, [], _mode]] call TC2_fnc_netToUnit;
};

private _side = side (group _unit);
private _base = _entry select 4;
private _sources = [];

// İHA'lar
if (missionNamespace getVariable ["TC2_cam_uavShare", true]) then {
    {
        private _uav = _x;
        if (unitIsUAV _uav && {alive _uav} && {!(_uav getVariable ["TC2_camHidden", false])}) then {
            private _uavSide = if ((crew _uav) isEqualTo []) then {
                [east, west, independent, civilian] select (((getNumber (configFile >> "CfgVehicles" >> typeOf _uav >> "side")) max 0) min 3)
            } else {
                side (group (effectiveCommander _uav))
            };
            if (_uavSide isEqualTo _side) then {
                _sources pushBack ["UAV", netId _uav, [format ["İHA  %1", getText (configFile >> "CfgVehicles" >> typeOf _uav >> "displayName")], 40] call TC2_fnc_netSanitize];
            };
        };
    } forEach vehicles;
};

// Kask kameraları
private _item = toLower (missionNamespace getVariable ["TC2_cam_helmetItem", "TC2_HelmetCam"]);
if !(_item isEqualTo "") then {
    // Telsiz yoksa menzil hesaplanamaz: sınır uygulanmaz.
    private _limit = (missionNamespace getVariable ["TC2_cam_helmetRange", true]) && {!(_base isEqualTo "")};
    private _range = [_base] call TC2_fnc_netRangeOf;
    {
        private _man = _x;
        if (
            !(_man isEqualTo _unit) && {alive _man} && {(side (group _man)) isEqualTo _side}
            && {_item in ((items _man + assignedItems _man) apply {toLower _x})}
            && {!_limit || {(_unit distance _man) <= _range}}
        ) then {
            _sources pushBack ["HELM", netId _man, [format ["KASK  %1 %2", groupId (group _man), name _man], 40] call TC2_fnc_netSanitize];
        };
    } forEach allUnits;
};

_sources = _sources select [0, 30];

[_unit, "TC2_fnc_camOnData", ["OK", _level, true, _sources, _mode]] call TC2_fnc_netToUnit;
