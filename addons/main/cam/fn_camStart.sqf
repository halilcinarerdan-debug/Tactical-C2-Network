/*
    Fonksiyon: TC2_fnc_camStart
    Çalışma yeri: İSTEMCİ

    Seçilen kaynağın görüntüsünü başlatır (YALNIZCA İZLEME). Yerel bir kamera nesnesi kaynağa iliştirilir ve görüntü bir dokuya (r2t) yazılır;
    terminal resmi bu dokuyu gösterir. İHA'ya bağlanılmaz, hiçbir kontrol komutu gönderilmez.
      İHA:  kamera gövdenin altına iliştirilir; yönü İHA'nın pilot kamerasını (getPilotCameraRotation) izler (camTick, 10 Hz).
      Kask: kamera askerin "head" noktasına iliştirilir (kafa hareketini izler).
    Kaynak bu istemciye aktarılmıyorsa (nesne yok) görüntü alınamaz; durum satırı söyler.
    Maliyet: ek bir render geçişi; yalnızca bu sekme açıkken ve kaynak seçiliyken. Doku 1024x512.

    Parametreler:
        0: tür <STRING>  "UAV" | "HELM"
        1: netId <STRING>

    Dönüş: yok
*/

params [["_kind", "", [""]], ["_netId", "", [""]]];

call TC2_fnc_camStop;

private _object = objectFromNetId _netId;
private _display = findDisplay 92000;
if (isNull _display) exitWith {};

if (isNull _object || {!alive _object}) exitWith {
    missionNamespace setVariable ["TC2_cam_statusText", "Kaynak bu istemciye aktarılmıyor ya da etkisiz; görüntü alınamıyor."];
    call TC2_fnc_camUiUpdate;
};

private _camera = "camera" camCreate [0, 0, 0];
_camera camSetFov ([0.7, 0.9] select (_kind isEqualTo "HELM"));
_camera camCommit 0;

if (_kind isEqualTo "UAV") then {
    _camera attachTo [_object, [0, 0.4, -0.5]];
} else {
    _camera attachTo [_object, [0.02, 0.12, 0.09], "head"];
    _camera setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];
};

_camera cameraEffect ["INTERNAL", "BACK", "tc2_cam_rtt"];
"tc2_cam_rtt" setPiPEffect [missionNamespace getVariable ["TC2_cam_mode", 0]];

(_display displayCtrl 92901) ctrlSetText "#(argb,1024,512,1)r2t(tc2_cam_rtt,1.8)";

missionNamespace setVariable ["TC2_cam_camera", _camera];
missionNamespace setVariable ["TC2_cam_source", [_kind, _object]];
missionNamespace setVariable ["TC2_cam_current", format ["%1:%2", _kind, _netId]];
missionNamespace setVariable ["TC2_cam_statusText", "Yayın açık (yalnızca izleme)"];

private _handle = [TC2_fnc_camTick, 0.1, []] call CBA_fnc_addPerFrameHandler;
missionNamespace setVariable ["TC2_cam_handle", _handle];
missionNamespace setVariable ["TC2_cam_tick", 0];

[missionNamespace getVariable ["TC2_cam_mode", 0]] call TC2_fnc_camUiMode;
call TC2_fnc_camTick;
call TC2_fnc_camUiUpdate;
