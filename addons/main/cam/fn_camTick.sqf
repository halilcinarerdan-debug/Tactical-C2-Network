/*
    Fonksiyon: TC2_fnc_camTick
    Çalışma yeri: İSTEMCİ (CBA PerFrameHandler, gecikme 0.1 sn; yalnızca bir kamera yayını açıkken) ya da doğrudan çağrı

    İHA yayınında kameranın yönünü İHA'nın pilot kamerasına (gimbal) eşler; saniyede bir de bilgi panelini yazar. Kaynak yok olursa ya da pencere
    kapanırsa yayın kendiliğinden durur. Hiçbir komut gönderilmez.

    Parametreler: PFH standardı [[args], handle] ya da hiçbiri
    Dönüş: yok
*/

private _display = findDisplay 92000;
private _source = missionNamespace getVariable ["TC2_cam_source", []];
private _camera = missionNamespace getVariable ["TC2_cam_camera", objNull];

if (isNull _display || {_source isEqualTo []} || {isNull _camera}) exitWith {call TC2_fnc_camStop};

_source params ["_kind", "_object"];

if (isNull _object || {!alive _object}) exitWith {
    call TC2_fnc_camStop;
    missionNamespace setVariable ["TC2_cam_statusText", "Kaynak etkisiz / bağlantı koptu."];
    call TC2_fnc_camUiUpdate;
};

// İHA: kamera yönü = pilot kamerası (gövdeye göre azimut / yükselme)
if (_kind isEqualTo "UAV") then {
    private _rotation = getPilotCameraRotation _object;
    private _azimuth = _rotation param [0, 0];
    private _elevation = _rotation param [1, -15];
    _camera setVectorDirAndUp [
        [(sin _azimuth) * (cos _elevation), (cos _azimuth) * (cos _elevation), sin _elevation],
        [0, 0, 1]
    ];
};

// bilgi paneli: saniyede bir
private _count = (missionNamespace getVariable ["TC2_cam_tick", 0]) + 1;
missionNamespace setVariable ["TC2_cam_tick", _count];
if (_count % 10 != 1) exitWith {};

private _grid = mapGridPosition _object;
private _half = floor ((count _grid) / 2);
private _text = if (_kind isEqualTo "UAV") then {
    format [
        "<t color='#40ff59'>%1</t><br/><t color='#1f9930'>TÜR</t>  İHA (insansız hava aracı)<br/><t color='#1f9930'>İRTİFA</t>  %2 m (yerden)<br/><t color='#1f9930'>HIZ</t>  %3 km/s<br/><t color='#1f9930'>YÖN</t>  %4°<br/><t color='#1f9930'>GRİD</t>  %5 %6<br/><t color='#1f9930'>KAMERA</t>  yön %7°  eğim %8°<br/><br/><t color='#ffcc33'>YALNIZCA İZLEME</t>  kontrol yok",
        getText (configFile >> "CfgVehicles" >> typeOf _object >> "displayName"),
        round ((getPosATL _object) select 2), round (speed _object), round (getDir _object),
        _grid select [0, _half], _grid select [_half, _half],
        round ((getPilotCameraRotation _object) param [0, 0]), round ((getPilotCameraRotation _object) param [1, 0])
    ]
} else {
    format [
        "<t color='#40ff59'>%1 %2</t><br/><t color='#1f9930'>TÜR</t>  kask kamerası<br/><t color='#1f9930'>YÖN</t>  %3°<br/><t color='#1f9930'>GRİD</t>  %4 %5<br/><t color='#1f9930'>DURUM</t>  %6<br/><br/><t color='#ffcc33'>YALNIZCA İZLEME</t>",
        groupId (group _object), name _object, [_object] call TC2_fnc_copHeading,
        _grid select [0, _half], _grid select [_half, _half],
        ["sağlam", "yaralı"] select ((damage _object) > 0.3)
    ]
};
(_display displayCtrl 92902) ctrlSetStructuredText parseText format ["<t size='0.8'>%1</t>", _text];
