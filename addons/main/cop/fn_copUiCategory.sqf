/*
    Fonksiyon: TC2_fnc_copUiCategory
    Çalışma yeri: İstemci (kategori listesi olayı / copUiBuild)

    Seçili kategorinin türlerini tür listesine (92071) yazar ve ilk türü seçer; seçilen tür kodu TC2_cop_placeType'a gider.

    Parametreler:
        0: seçimi uygula <BOOL>  (varsayılan true; build sırasında da çağrılır)

    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

private _category = _display displayCtrl 92070;
private _type = _display displayCtrl 92071;
if (isNull _category || {isNull _type}) exitWith {};

private _catalog = [] call TC2_fnc_copTypeCatalog;
private _index = (lbCurSel _category) max 0;
private _entries = (_catalog select (_index min ((count _catalog) - 1))) select 1;

lbClear _type;
{
    private _row = _type lbAdd (_x select 1);
    _type lbSetData [_row, _x select 0];
    _type lbSetPicture [_row, _x select 2];
} forEach _entries;
_type lbSetCurSel 0;

missionNamespace setVariable ["TC2_cop_placeType", (_entries select 0) select 0];
