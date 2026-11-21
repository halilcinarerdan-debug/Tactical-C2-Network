/*
    Fonksiyon: TC2_fnc_camStop
    Çalışma yeri: İSTEMCİ (sekme değişince, pencere kapanınca, kaynak kaybolunca)

    Kamera yayınını durdurur: PFH'yi kaldırır, kamerayı yok eder, resmi boşaltır. Çalışan yayın yoksa hiçbir şey yapmaz. Render yükü kalmaz.

    Parametreler: yok
    Dönüş: yok
*/

private _handle = missionNamespace getVariable ["TC2_cam_handle", -1];
if (_handle >= 0) then {[_handle] call CBA_fnc_removePerFrameHandler};
missionNamespace setVariable ["TC2_cam_handle", -1];

private _camera = missionNamespace getVariable ["TC2_cam_camera", objNull];
if (!isNull _camera) then {
    _camera cameraEffect ["TERMINATE", "BACK"];
    camDestroy _camera;
};
missionNamespace setVariable ["TC2_cam_camera", objNull];
missionNamespace setVariable ["TC2_cam_source", []];

if !((missionNamespace getVariable ["TC2_cam_current", ""]) isEqualTo "") then {
    missionNamespace setVariable ["TC2_cam_current", ""];
    private _display = findDisplay 92000;
    if (!isNull _display) then {
        (_display displayCtrl 92901) ctrlSetText "";
        private _combo = _display displayCtrl 92900;
        if (!isNull _combo && {(lbCurSel _combo) > 0}) then {_combo lbSetCurSel 0};
    };
};
