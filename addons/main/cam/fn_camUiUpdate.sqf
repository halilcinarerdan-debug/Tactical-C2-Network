/*
    Fonksiyon: TC2_fnc_camUiUpdate
    Çalışma yeri: İstemci

    KAMERA sekmesini günceller: görünürlük (yalnızca KAMERA sekmesinde), kaynak listesi (değişince; seçim korunur), yetkisizse açıklama, durum satırı.
    Seçili kaynak listeden kaybolduysa (İHA düştü, kask eşyası çıkarıldı, menzil dışı) yayın durdurulur.
    Yetkisiz (Level 1 ya da izleme) durumda liste ve görüntü GİZLİ, yalnızca açıklama görünür.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display || {isNull (_display displayCtrl 92900)}) exitWith {};

(missionNamespace getVariable ["TC2_cam_data", ["EMPTY", 1, false, []]]) params ["_code", "_level", "_canView", "_sources"];

private _onTab = (missionNamespace getVariable ["TC2_ui_tab", 0]) == 9;
private _ok = _code isEqualTo "OK";

{(_display displayCtrl _x) ctrlShow (_onTab && _canView)} forEach [92900, 92901, 92903, 92904, 92905, 92907];
(_display displayCtrl 92902) ctrlShow _onTab;
(_display displayCtrl 92906) ctrlShow _onTab;

if (!_onTab) exitWith {};

if (!_canView) exitWith {
    call TC2_fnc_camStop;
    private _text = if (!_ok) then {format ["BAĞLANTI YOK | %1", [_code] call TC2_fnc_accessReasonText]} else {"KAMERA sekmesi Level 2 (Mavi kart) ve üstü içindir; izleme modunda kamera görünmez."};
    (_display displayCtrl 92902) ctrlSetStructuredText parseText format ["<t size='0.8'>%1</t>", _text];
    (_display displayCtrl 92906) ctrlSetText "  KAMERA: yetki yok";
};

// kaynak listesi
private _combo = _display displayCtrl 92900;
private _signature = str (_sources apply {_x select 1});
if !(_signature isEqualTo (missionNamespace getVariable ["TC2_cam_sig", ""])) then {
    missionNamespace setVariable ["TC2_cam_sig", _signature];
    [_combo, _sources apply {[_x select 2, format ["%1:%2", _x select 0, _x select 1]]}, [format ["— kamera kaynağı seçin (%1) —", count _sources], ""]] call TC2_fnc_uiFillCombo;
};

// seçili kaynak artık listede değilse yayını kes
private _current = missionNamespace getVariable ["TC2_cam_current", ""];
if (!(_current isEqualTo "") && {count (_sources select {(format ["%1:%2", _x select 0, _x select 1]) isEqualTo _current}) == 0}) then {
    call TC2_fnc_camStop;
    missionNamespace setVariable ["TC2_cam_statusText", "Kaynak bağlantısı koptu / kapsam dışı."];
};

if ((missionNamespace getVariable ["TC2_cam_current", ""]) isEqualTo "") then {
    (_display displayCtrl 92902) ctrlSetStructuredText parseText format [
        "<t size='0.8'>%1 kaynak var.<br/>Üstteki listeden bir İHA ya da kask kamerası seçin.<br/><br/><t color='#ffcc33'>YALNIZCA İZLEME:</t> İHA kontrol edilemez, silah/hedefleme yoktur.<br/>Görüntü için oyun video ayarlarında <t color='#40ff59'>PiP (resim içinde resim)</t> açık olmalıdır.</t>",
        count _sources
    ];
};

private _status = missionNamespace getVariable ["TC2_cam_statusText", ""];
if (_status isEqualTo "") then {_status = format ["Level %1 | %2 kaynak", _level, count _sources]};
(_display displayCtrl 92906) ctrlSetText ("  " + _status);
