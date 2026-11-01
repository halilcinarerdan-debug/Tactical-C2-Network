/*
    Fonksiyon: TC2_fnc_copFriendsOf
    Çalışma yeri: SADECE SUNUCU (saf: yalnızca okur)

    İzleyicinin ağındaki dostları verir: aynı telsiz tipi + aynı kanal + izleyicinin telsiz menzili içinde,
    canlı, raporu taze (25 sn). Telsizi olan HERKES (saha birlikleri dahil) sayılır; terminalde oturum açık olması gerekmez.
    Ek olarak tabletli AI grup liderleri (copAiLeaders) aynı taraf ve menzil içindeyse eklenir.
    Test için debugNetPeer ile eklenen simüle eşler de dahildir.

    Parametreler:
        0: izleyici birim <OBJECT>
        1: telsiz tipi <STRING>
        2: kanal <NUMBER>
        3: LACE dahil mi <BOOL>  (yalnızca Level 2+ ve izleme modunda olmayan oturumlar için true; varsayılan false)

    Dönüş: [[konum ASL, etiket, lider mi, lace, bakış yönü derece]] <ARRAY>
        lace = lider ve istendiyse rptLaceInfo çıktısı [[mevcut, ilk, yaralı, araç %], son rapor], aksi halde []
*/

params [["_viewer", objNull, [objNull]], ["_base", "", [""]], ["_channel", -1, [0]], ["_includeLace", false, [false]]];

if (_base isEqualTo "" || {isNull _viewer}) exitWith {[]};

private _range = [_base] call TC2_fnc_netRangeOf;
private _now = diag_tickTime;
private _viewerNet = netId _viewer;
private _out = [];

{
    _x params ["_netId", "_unit", "", "_unitBase", "_unitChannel", "_time"];
    if (
        !(_netId isEqualTo _viewerNet) && {(_now - _time) < 25} && {alive _unit}
        && {_unitBase isEqualTo _base} && {_unitChannel == _channel} && {(_viewer distance _unit) <= _range}
    ) then {
        private _label = [format ["%1 %2", groupId (group _unit), name _unit], 40] call TC2_fnc_netSanitize;
        private _isLeader = (leader (group _unit)) isEqualTo _unit;
        _out pushBack [getPosASL _unit, _label, _isLeader, if (_includeLace && _isLeader) then {[group _unit] call TC2_fnc_rptLaceInfo} else {[]}, [_unit] call TC2_fnc_copHeading];
    };
} forEach (missionNamespace getVariable ["TC2_cop_field", []]);

// AI grup liderleri (tabletli): aynı taraf, izleyicinin telsiz menzili içinde. AI telsiz tipi/kanalı taşımaz; menzil, izleyicinin telsiz tipinindir.
{
    _x params ["_aiUnit", "_aiSide"];
    if (alive _aiUnit && {_aiSide isEqualTo (side (group _viewer))} && {!(_aiUnit isEqualTo _viewer)} && {(_viewer distance _aiUnit) <= _range}) then {
        _out pushBack [
            getPosASL _aiUnit,
            [format ["%1 AI", groupId (group _aiUnit)], 40] call TC2_fnc_netSanitize,
            true,
            if (_includeLace) then {[group _aiUnit] call TC2_fnc_rptLaceInfo} else {[]},
            [_aiUnit] call TC2_fnc_copHeading
        ];
    };
} forEach ([] call TC2_fnc_copAiLeaders);

// Simüle test eşleri (net kayıtları: 0 netId 1 birim 2 etiket 3 telsiz 4 tip 5 kanal 6 zaman 7 sim)
{
    if ((_x select 7) && {(_x select 4) isEqualTo _base} && {(_x select 5) == _channel} && {alive (_x select 1)} && {(_viewer distance (_x select 1)) <= _range}) then {
        private _simUnit = _x select 1;
        private _simLeader = (leader (group _simUnit)) isEqualTo _simUnit;
        _out pushBack [getPosASL _simUnit, _x select 2, _simLeader, if (_includeLace && _simLeader) then {[group _simUnit] call TC2_fnc_rptLaceInfo} else {[]}, [_simUnit] call TC2_fnc_copHeading];
    };
} forEach (missionNamespace getVariable ["TC2_net_sessions", []]);

_out
