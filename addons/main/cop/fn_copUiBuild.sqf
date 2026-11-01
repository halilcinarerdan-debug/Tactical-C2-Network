/*
    Fonksiyon: TC2_fnc_copUiBuild
    Çalışma yeri: İstemci (uiOpen çağırır, pencere kurulurken)

    HARİTA sekmesinin kontrollerini kurar. Hepsi varsayılan olarak GİZLİDİR; uiSelectTab yalnızca HARİTA sekmesinde gösterir.
        92040 harita (RscMapControl)   92041 DÜŞMAN PİYADE düğmesi   92042 İŞARET SİL düğmesi   92043 durum satırı
        92044 BİRİM / LACE düğmesi (tıklanan dost liderin LACE bilgisi)   92046 LACE paneli (haritanın üstünde, varsayılan boş)

    Harita yalnızca terminalin kendi kontrolüdür: işaretler ve dostlar BURADA çizilir (drawIcon), normal Arma
    haritasına hiçbir şey eklenmez. Çizim olayı (Draw) harita görünürken çalışır, gizliyken çalışmaz.

    Parametreler:
        0: pencere <DISPLAY>
        1: sol <NUMBER>      içerik alanı sol kenarı
        2: üst <NUMBER>      içerik alanı üst kenarı
        3: genişlik <NUMBER>
        4: yükseklik <NUMBER>

    Dönüş: yok
*/

params ["_display", "_left", "_top", "_width", "_height"];

private _green = [0.25, 1, 0.35, 1];
private _rowH = 0.045;
private _gap = 0.01;

private _placeButton = _display ctrlCreate ["RscButtonMenu", 92041];
_placeButton ctrlSetPosition [_left, _top, 0.2, _rowH];
_placeButton ctrlSetText "DÜŞMAN PİYADE";
_placeButton ctrlSetTextColor [1, 0.5, 0.5, 1];
_placeButton ctrlAddEventHandler ["ButtonClick", {["PLACE"] call TC2_fnc_copUiMode}];
_placeButton ctrlShow false;
_placeButton ctrlCommit 0;

private _deleteButton = _display ctrlCreate ["RscButtonMenu", 92042];
_deleteButton ctrlSetPosition [_left + 0.2 + _gap, _top, 0.17, _rowH];
_deleteButton ctrlSetText "İŞARET SİL";
_deleteButton ctrlSetTextColor _green;
_deleteButton ctrlAddEventHandler ["ButtonClick", {["DELETE"] call TC2_fnc_copUiMode}];
_deleteButton ctrlShow false;
_deleteButton ctrlCommit 0;

private _infoButton = _display ctrlCreate ["RscButtonMenu", 92044];
_infoButton ctrlSetPosition [_left + 0.37 + _gap, _top, 0.2, _rowH];
_infoButton ctrlSetText "BİRİM / LACE";
_infoButton ctrlSetTextColor _green;
_infoButton ctrlAddEventHandler ["ButtonClick", {["INFO"] call TC2_fnc_copUiMode}];
_infoButton ctrlShow false;
_infoButton ctrlCommit 0;

private _statusLeft = _left + 0.57 + 2 * _gap;
private _status = _display ctrlCreate ["RscText", 92043];
_status ctrlSetPosition [_statusLeft, _top, _width - (_statusLeft - _left), _rowH];
_status ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
_status ctrlSetTextColor _green;
_status ctrlShow false;
_status ctrlCommit 0;

private _mapTop = _top + _rowH + _gap;
private _map = _display ctrlCreate ["RscMapControl", 92040];
_map ctrlSetPosition [_left, _mapTop, _width, _height - (_mapTop - _top)];
_map ctrlAddEventHandler ["Draw", {call TC2_fnc_copUiDraw}];
_map ctrlAddEventHandler ["MouseButtonClick", {call TC2_fnc_copUiClick}];
_map ctrlShow false;
_map ctrlCommit 0;
_map ctrlMapAnimAdd [0, 0.15, getPosASL ACE_player];
ctrlMapAnimCommit _map;

// LACE paneli: haritanın üst kenarında, yalnızca INFO modunda ve bir birim seçiliyken görünür (uiSelectTab 92046'yı yönetmez; copUiMode yönetir).
private _panel = _display ctrlCreate ["RscStructuredText", 92046];
_panel ctrlSetPosition [_left + 0.005, _mapTop + 0.005, _width * 0.55, 0.16];
_panel ctrlSetBackgroundColor [0, 0.05, 0.01, 0.92];
_panel ctrlShow false;
_panel ctrlCommit 0;

missionNamespace setVariable ["TC2_cop_mode", ""];
