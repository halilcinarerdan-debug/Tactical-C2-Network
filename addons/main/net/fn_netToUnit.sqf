/*
    Fonksiyon: TC2_fnc_netToUnit
    Çalışma yeri: Her makine

    Bir fonksiyonu bir birimin bulunduğu makinede çalıştırır: birim yereldeyse doğrudan çağırır
    (host / tek oyunculu / sunucudaki AI), değilse yalnızca o makineye remoteExecCall eder.
    Fonksiyon adı CfgRemoteExec beyaz listesinde olmalıdır.

    Parametreler:
        0: birim <OBJECT>
        1: fonksiyon adı <STRING>  örn. "TC2_fnc_netReceive"
        2: argümanlar <ARRAY>

    Dönüş: yok
*/

params [["_unit", objNull, [objNull]], ["_function", "", [""]], ["_args", [], [[]]]];

if (isNull _unit || {_function isEqualTo ""}) exitWith {};

if (local _unit) then {
    _args call (missionNamespace getVariable [_function, {}]);
} else {
    _args remoteExecCall [_function, owner _unit];
};
