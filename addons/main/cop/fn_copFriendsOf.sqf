/*
    Fonksiyon: TC2_fnc_copFriendsOf
    Çalışma yeri: SADECE SUNUCU (saf: yalnızca okur)

    İzleyicinin ağındaki dostları verir: aynı telsiz tipi + aynı kanal + izleyicinin telsiz menzili içinde,
    canlı, raporu taze (25 sn). Telsizi olan HERKES (saha birlikleri dahil) sayılır; terminalde oturum açık olması gerekmez.
    Test için debugNetPeer ile eklenen simüle eşler de dahildir.

    Parametreler:
        0: izleyici birim <OBJECT>
        1: telsiz tipi <STRING>
        2: kanal <NUMBER>

    Dönüş: [[konum ASL, etiket, lider mi]] <ARRAY>
*/

params [["_viewer", objNull, [objNull]], ["_base", "", [""]], ["_channel", -1, [0]]];

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
        _out pushBack [getPosASL _unit, _label, (leader (group _unit)) isEqualTo _unit];
    };
} forEach (missionNamespace getVariable ["TC2_cop_field", []]);

// Simüle test eşleri (net kayıtları: 0 netId 1 birim 2 etiket 3 telsiz 4 tip 5 kanal 6 zaman 7 sim)
{
    if ((_x select 7) && {(_x select 4) isEqualTo _base} && {(_x select 5) == _channel} && {alive (_x select 1)} && {(_viewer distance (_x select 1)) <= _range}) then {
        _out pushBack [getPosASL (_x select 1), _x select 2, false];
    };
} forEach (missionNamespace getVariable ["TC2_net_sessions", []]);

_out
