/*
    Fonksiyon: TC2_fnc_copUiBuild
    Çalışma yeri: İstemci (uiOpen çağırır, pencere kurulurken)

    HARİTA sekmesinin kontrollerini kurar. Hepsi varsayılan olarak GİZLİDİR; uiSelectTab yalnızca HARİTA sekmesinde gösterir.
      Satır 1 (araçlar):  92041 DÜŞMAN PİYADE   92042 İŞARET SİL   92044 BİRİM / LACE   92045 ÖLÇ   92047 MERKEZ   92048 KATMAN
      Satır 2 (bilgi):    92043 durum / talimat satırı   92049 canlı imleç bilgisi (grid, yükseklik, mesafe, yön)
      Harita:             92040 (RscMapControl)   92046 LACE paneli (haritanın üstünde)

    Harita yalnızca terminalin kendi kontrolüdür: işaretler ve dostlar BURADA çizilir (drawIcon), normal Arma
    haritasına hiçbir şey eklenmez. Çizim olayı (Draw) harita görünürken çalışır, gizliyken çalışmaz.

    ATAK'tan alınan fikirler (arayüzü boğmadan): imleç altındaki grid + yükseklik (canlı), ÖLÇ (iki nokta arası mesafe / yön / yükseklik farkı),
    MERKEZ (kendi konumuma git), oyundaki harita işaretlerini gösteren KATMAN.

    Parametreler:
        0: pencere <DISPLAY>   1: sol   2: üst   3: genişlik   4: yükseklik   (içerik alanı)

    Dönüş: yok
*/

params ["_display", "_left", "_top", "_width", "_height"];

private _green = [0.25, 1, 0.35, 1];
private _rowH = 0.04;
private _gap = 0.008;
private _bw = (_width - 5 * _gap) / 6;

private _tool = {
    params ["_idc", "_index", "_text", "_color", "_code"];
    private _button = _display ctrlCreate ["RscButtonMenu", _idc];
    _button ctrlSetPosition [_left + _index * (_bw + _gap), _top, _bw, _rowH];
    _button ctrlSetText _text;
    _button ctrlSetFontHeight 0.028;
    _button ctrlSetTextColor _color;
    _button ctrlAddEventHandler ["ButtonClick", _code];
    _button ctrlShow false;
    _button ctrlCommit 0;
};

[92041, 0, "DÜŞMAN PİYADE", [1, 0.5, 0.5, 1], {["PLACE"] call TC2_fnc_copUiMode}] call _tool;
[92042, 1, "İŞARET SİL", _green, {["DELETE"] call TC2_fnc_copUiMode}] call _tool;
[92044, 2, "BİRİM / LACE", _green, {["INFO"] call TC2_fnc_copUiMode}] call _tool;
[92045, 3, "ÖLÇ", _green, {["MEASURE"] call TC2_fnc_copUiMode}] call _tool;
[92047, 4, "MERKEZ", _green, {
    private _map = (findDisplay 92000) displayCtrl 92040;
    _map ctrlMapAnimAdd [0.3, ctrlMapScale _map, getPosASL ACE_player];
    ctrlMapAnimCommit _map;
}] call _tool;
[92048, 5, "KATMAN: AÇIK", _green, {
    private _on = !(missionNamespace getVariable ["TC2_cop_layer", true]);
    missionNamespace setVariable ["TC2_cop_layer", _on];
    (_this select 0) ctrlSetText (["KATMAN: KAPALI", "KATMAN: AÇIK"] select _on);
    if (_on) then {call TC2_fnc_copGameMarkers} else {missionNamespace setVariable ["TC2_cop_gameMarkers", []]};
}] call _tool;

private _rowTwo = _top + _rowH + _gap;
private _statusW = _width * 0.45;

private _status = _display ctrlCreate ["RscText", 92043];
_status ctrlSetPosition [_left, _rowTwo, _statusW, _rowH];
_status ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
_status ctrlSetTextColor _green;
_status ctrlSetFontHeight 0.026;
_status ctrlShow false;
_status ctrlCommit 0;

private _readout = _display ctrlCreate ["RscText", 92049];
_readout ctrlSetPosition [_left + _statusW + _gap, _rowTwo, _width - _statusW - _gap, _rowH];
_readout ctrlSetBackgroundColor [0, 0.06, 0.02, 1];
_readout ctrlSetTextColor [0.7, 1, 0.75, 1];
_readout ctrlSetFontHeight 0.026;
_readout ctrlSetText "  imleci haritada gezdirin: grid / yükseklik / mesafe";
_readout ctrlShow false;
_readout ctrlCommit 0;

private _mapTop = _rowTwo + _rowH + _gap;
private _map = _display ctrlCreate ["RscMapControl", 92040];
_map ctrlSetPosition [_left, _mapTop, _width, _height - (_mapTop - _top)];
_map ctrlAddEventHandler ["Draw", {call TC2_fnc_copUiDraw}];
_map ctrlAddEventHandler ["MouseButtonClick", {call TC2_fnc_copUiClick}];
_map ctrlAddEventHandler ["MouseMoving", {call TC2_fnc_copUiCursor}];
_map ctrlShow false;
_map ctrlCommit 0;
_map ctrlMapAnimAdd [0, 0.15, getPosASL ACE_player];
ctrlMapAnimCommit _map;

// LACE paneli: haritanın üst kenarında, yalnızca INFO modunda ve bir birim seçiliyken görünür (copUiMode yönetir).
private _panel = _display ctrlCreate ["RscStructuredText", 92046];
_panel ctrlSetPosition [_left + 0.005, _mapTop + 0.005, _width * 0.6, 0.16];
_panel ctrlSetBackgroundColor [0, 0.05, 0.01, 0.92];
_panel ctrlSetFontHeight 0.028;
_panel ctrlShow false;
_panel ctrlCommit 0;

missionNamespace setVariable ["TC2_cop_mode", ""];
missionNamespace setVariable ["TC2_cop_measure", []];
missionNamespace setVariable ["TC2_cop_cursor", []];
missionNamespace setVariable ["TC2_cop_layer", true];
missionNamespace setVariable ["TC2_cop_gameMarkers", []];
