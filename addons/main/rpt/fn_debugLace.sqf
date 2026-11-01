/*
    Fonksiyon: TC2_fnc_debugLace
    Çalışma yeri: SADECE SUNUCU (debug konsolunda "Server Exec"; host'ta "Local Exec" da olur)

    TEST YARDIMCISI: bir AI liderin (debugNetPeer ile ağa eklenmiş) grubu adına LACE raporu yazar. Gerçek akıştaki rptSend'in
    yetki ve ağ denetimlerinden geçmez; yalnızca haritadaki LACE panelini tek başına denemek içindir.

    Parametreler:
        0: lider birim <OBJECT>
        1: veri <ARRAY of STRING>  8 metin: [Liquids durumu, not, Ammunition durumu, not, Casualties durumu, not, Equipment durumu, not]
           durum: GREEN | AMBER | RED | BLACK

    Dönüş: başarılı mı <BOOL>

    Örnek:
        [TC2_p, ["GREEN", "", "AMBER", "yarisi kaldi", "GREEN", "", "RED", "1 arac arizali"]] call TC2_fnc_debugLace;
*/

if (!isServer) exitWith {false};

params [["_unit", objNull, [objNull]], ["_data", [], [[]]]];

if (isNull _unit) exitWith {false};

private _check = ["LACE", _data] call TC2_fnc_rptValidate;
if !(_check select 0) exitWith {
    diag_log format ["[TC2][RAPOR] debugLace gecersiz: %1", _check select 1];
    false
};

private _entry = [];
{
    if ((_x select 1) isEqualTo _unit) exitWith {_entry = _x};
} forEach (missionNamespace getVariable ["TC2_net_sessions", []]);

private _id = (missionNamespace getVariable ["TC2_rpt_nextId", 0]) + 1;
missionNamespace setVariable ["TC2_rpt_nextId", _id];

private _reports = missionNamespace getVariable ["TC2_reports", []];
_reports pushBack [
    _id, "LACE", netId _unit, [groupId (group _unit), 24] call TC2_fnc_netSanitize, _data, diag_tickTime,
    if (_entry isEqualTo []) then {"ACRE_PRC343"} else {_entry select 4},
    if (_entry isEqualTo []) then {1} else {_entry select 5},
    false, getPosASL _unit, netId (group _unit), ([group _unit] call TC2_fnc_rptLaceInfo) select 0, _unit
];
missionNamespace setVariable ["TC2_reports", _reports];

diag_log format ["[TC2][RAPOR] debugLace id=%1 birim=%2", _id, name _unit];
true
