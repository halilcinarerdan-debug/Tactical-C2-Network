/*
    Fonksiyon: TC2_fnc_debugHelmetCam
    Çalışma yeri: İstemci / birimin yerel olduğu makine (debug konsolu "Local Exec"); AI için sunucuda

    TEST YARDIMCISI: bir askere kask kamerası eşyasını (CBA TC2_cam_helmetItem; varsayılan TC2_HelmetCam) verir ya da alır.

    Parametreler:
        0: birim <OBJECT>  (varsayılan: cursorObject; yoksa player)
        1: ver mi? <BOOL>  true = ver (varsayılan), false = al

    Dönüş: yok

    Örnek: [cursorObject] call TC2_fnc_debugHelmetCam;     // baktığınız AI/oyuncuya kask kamerası ver
*/

params [["_unit", objNull, [objNull]], ["_give", true, [true]]];

if (isNull _unit) then {_unit = if (!isNull cursorObject && {cursorObject isKindOf "CAManBase"}) then {cursorObject} else {player}};

private _item = missionNamespace getVariable ["TC2_cam_helmetItem", "TC2_HelmetCam"];
if (_item isEqualTo "") exitWith {};

if (_give) then {_unit addItem _item} else {_unit removeItems _item};
