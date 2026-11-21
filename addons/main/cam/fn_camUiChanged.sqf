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

// Veri biçimi "TÜR:netId" ve netId'nin kendisi iki noktalıdır ("2:15"): yalnızca İLK iki noktada böl.
private _split = _data find ":";
[_data select [0, _split], _data select [_split + 1, (count _data) - _split - 1]] call TC2_fnc_camStart;
