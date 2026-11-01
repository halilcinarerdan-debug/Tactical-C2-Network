/*
    Fonksiyon: TC2_fnc_medPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf, hasInterface kontrolünden sonra)

    Hava aracı mürettebatı tarafı: ACE self menüsüne "TC2 MEDEVAC" ekler. Gelen talep varsa görünür, uçak/helikopter içinde de çalışır.
    Her talep için iki alt eylem üretilir (menü açılırken, yalnızca o an): "#id OKU" (9 satırı göster) ve "#id KABUL".
    Tek bir kez, CAManBase sınıfına eklenir (respawn/JIP için ek iş yok).

    Parametreler: yok
    Dönüş: yok
*/

missionNamespace setVariable ["TC2_med_incoming", []];

private _parent = [
    "TC2_med_menu",
    "TC2 MEDEVAC",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\heal_ca.paa",
    {},
    {
        params ["_target", "_player"];
        (vehicle _player) isKindOf "Air" && {count (missionNamespace getVariable ["TC2_med_incoming", []]) > 0}
    },
    {
        params ["_target", "_player"];
        private _children = [];
        {
            _x params ["_id", "_callsign", "", "_state", "_acceptor"];
            private _label = format ["#%1 %2", _id, _callsign];
            _children pushBack [[
                format ["TC2_med_read_%1", _id], format ["%1  OKU", _label], "", {
                    params ["", "", "_params"];
                    ["READ", _params select 0] call TC2_fnc_medCrewAction;
                }, {true}, {}, [_id]
            ] call ace_interact_menu_fnc_createAction, [], _target];
            if (_state isEqualTo "OPEN") then {
                _children pushBack [[
                    format ["TC2_med_accept_%1", _id], format ["%1  KABUL", _label], "", {
                        params ["", "", "_params"];
                        ["ACCEPT", _params select 0] call TC2_fnc_medCrewAction;
                    }, {true}, {}, [_id]
                ] call ace_interact_menu_fnc_createAction, [], _target];
            };
        } forEach (missionNamespace getVariable ["TC2_med_incoming", []]);
        _children
    }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _parent, true] call ace_interact_menu_fnc_addActionToClass;
