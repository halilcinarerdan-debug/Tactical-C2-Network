/*
    Fonksiyon: TC2_fnc_terminalCreate
    Çalışma yeri: SADECE sunucu (debug konsolunda "Server Exec"; host'ta "Local Exec" da olur)

    Çalışma zamanında bir TC2 terminali yaratır. Eden'de elle yerleştirmek için bu fonksiyon gerekmez
    (Objects > Tactical C2 Network > Terminals).

    MP / JIP:
      - createVehicle global etkilidir; obje tüm makinelerde ve JIP oyunculara görünür.
      - ACE eylemi sınıfa bağlı olduğundan ayrıca bir şey senkronlamak gerekmez.
      - Terminal kimliği global setVariable ile yayınlanır (JIP'e de iletilir).

    Parametreler:
        0: konum <ARRAY>   ATL [x,y,z] (z verilmezse 0). Not: sunucuda `player` null'dır,
                           konumu literal ya da allPlayers ile ver.
        1: yön <NUMBER>    derece (varsayılan 0)
        2: kimlik <STRING> terminal kimliği, örn. "TOC-ANA" (varsayılan: "" -> netId kullanılır)

    Dönüş: yaratılan terminal <OBJECT> (sunucu değilse objNull)
*/

params [["_pos", [0, 0, 0], [[]], [2, 3]], ["_dir", 0, [0]], ["_id", "", [""]]];

if (!isServer) exitWith {
    diag_log "[TC2][TERMINAL] terminalCreate yalnizca sunucuda calisir.";
    objNull
};

private _terminal = createVehicle ["TC2_Terminal_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];

if (isNull _terminal) exitWith {
    diag_log "[TC2][TERMINAL] createVehicle basarisiz (TC2_Terminal_F).";
    objNull
};

_terminal setDir _dir;
_terminal setPosATL [_pos select 0, _pos select 1, if (count _pos > 2) then {_pos select 2} else {0}];
_terminal setVectorUp [0, 0, 1];

if (_id != "") then {
    _terminal setVariable ["TC2_terminalId", _id, true];
};

diag_log format ["[TC2][TERMINAL] olusturuldu id=%1 pos=%2", [_terminal] call TC2_fnc_terminalGetId, getPosATL _terminal];

_terminal
