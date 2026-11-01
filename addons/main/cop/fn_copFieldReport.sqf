/*
    Fonksiyon: TC2_fnc_copFieldReport
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_copFieldReport", 2]
                  - host / tek oyunculuda: copHeartbeat doğrudan çağırır

    "Saha varlığı" kaydı (TC2_cop_field). Her kayıt:
        0 netId   1 birim   2 telsiz ID   3 telsiz taban sınıfı   4 kanal   5 son rapor zamanı   6 son DAGR özeti (hash)

    Doğrulamalar: gönderen (remoteExecutedOwner), birim canlı mı, telsiz gerçekten birimin envanterinde mi.
    Kanal istemciden gelir (sunucu ACRE durumunu okuyamaz) -> bilinen sınır. Eski kayıtlar (25 sn) silinir.
    Kayıttan sonra bu birimin MicroDAGR özeti hesaplanır; değiştiyse istemciye gönderilir (copSyncUnit).

    Parametreler:
        0: birim <OBJECT>
        1: telsiz durumu <ARRAY>  (netGetRadioState)

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_state", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _now = diag_tickTime;
private _netId = netId _unit;
private _field = (missionNamespace getVariable ["TC2_cop_field", []]) select {
    !isNull (_x select 1) && {(_now - (_x select 5)) < 25}
};

private _index = -1;
{
    if ((_x select 0) isEqualTo _netId) exitWith {_index = _forEachIndex};
} forEach _field;

_state params [["_has", false, [false]], ["_radioId", "", [""]], ["_base", "", [""]], ["_channel", -1, [0]]];

private _valid = _has && {alive _unit} && {(toLower _radioId) in ((items _unit) apply {toLower _x})};

if (!_valid) exitWith {
    if (_index >= 0) then {_field deleteAt _index};
    missionNamespace setVariable ["TC2_cop_field", _field];
};

private _hash = "[]";
if (_index >= 0) then {_hash = (_field select _index) select 6};

private _entry = [_netId, _unit, _radioId, _base, _channel, _now, _hash];

if (_index >= 0) then {
    _field set [_index, _entry];
} else {
    _field pushBack _entry;
};
missionNamespace setVariable ["TC2_cop_field", _field];

[_entry] call TC2_fnc_copSyncUnit;
