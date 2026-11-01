/*
    Fonksiyon: TC2_fnc_medCrewAction
    Çalışma yeri: İSTEMCİ (mürettebatın ACE self menüsü)

    "OKU": talebin 9 satırını ACE yapılı metniyle gösterir. "KABUL": talebi kabul eder (sunucu doğrular; ETA döner).

    Parametreler:
        0: eylem <STRING>  "READ" | "ACCEPT"
        1: talep id <NUMBER>

    Dönüş: yok
*/

params [["_action", "", [""]], ["_id", -1, [0]]];

private _request = [];
{
    if ((_x select 0) == _id) exitWith {_request = _x};
} forEach (missionNamespace getVariable ["TC2_med_incoming", []]);

if (_request isEqualTo []) exitWith {};

if (_action isEqualTo "READ") exitWith {
    _request params ["_id", "_callsign", "_lines", "_state", "_acceptor"];
    private _text = format ["<t size='1.1' color='#40ff59'>MEDEVAC #%1  %2</t>", _id, _callsign];
    {
        _text = _text + format ["<br/><t color='#1f9930'>%1</t>  %2", _x select 0, _x select 1];
    } forEach _lines;
    if !(_state isEqualTo "OPEN") then {
        _text = _text + format ["<br/><t color='#ffcc33'>DURUM: %1 %2</t>", _state, _acceptor];
    };
    [parseText _text, 12] call ace_common_fnc_displayTextStructured;
};

if (_action isEqualTo "ACCEPT") exitWith {
    if (isServer) then {
        [ACE_player, _id] call TC2_fnc_medRespond;
    } else {
        [ACE_player, _id] remoteExecCall ["TC2_fnc_medRespond", 2];
    };
};
