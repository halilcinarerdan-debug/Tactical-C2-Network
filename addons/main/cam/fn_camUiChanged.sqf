/*
    Fonksiyon: TC2_fnc_camUiChanged
    Çalışma yeri: İstemci (kaynak listesi olayı)

    Seçilen kaynağı başlatır; boş seçimde yayını durdurur. Liste yenilenirken (uiFillCombo seçimi geri yükler) aynı kaynak yeniden
    başlatılmaz.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

private _combo = _display displayCtrl 92900;
private _data = _combo lbData (lbCurSel _combo);

if (_data isEqualTo (missionNamespace getVariable ["TC2_cam_current", ""])) exitWith {};

if (_data isEqualTo "") exitWith {call TC2_fnc_camStop};

private _parts = _data splitString ":";
[_parts select 0, _parts select 1] call TC2_fnc_camStart;
