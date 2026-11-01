/*
    Fonksiyon: TC2_fnc_opordUiAction
    Çalışma yeri: İSTEMCİ (OPORD sekmesi düğmeleri)

    İşlemler: ACK (onay), SAVE (seçili bölümü kaydet; Level 3), TEMPLATE (şablon; Level 3, belge yokken), TOGGLE (yerel: düzenleme/okuma geçişi).
    Yetki ve kurallar sunucuda uygulanır (opordEdit); burada yalnızca istek gönderilir.

    Parametreler:
        0: işlem <STRING>

    Dönüş: yok
*/

params [["_action", "", [""]]];

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];
private _display = findDisplay 92000;
if (isNull _terminal || {isNull _display}) exitWith {};

if (_action isEqualTo "TOGGLE") exitWith {
    missionNamespace setVariable ["TC2_opord_edit", !(missionNamespace getVariable ["TC2_opord_edit", false])];
    missionNamespace setVariable ["TC2_opord_loadedKey", ""];
    call TC2_fnc_opordUiUpdate;
};

private _args = [];
if (_action isEqualTo "SAVE") then {
    private _sectionControl = _display displayCtrl 92600;
    private _levelControl = _display displayCtrl 92605;
    private _key = _sectionControl lbData (lbCurSel _sectionControl);
    if (_key isEqualTo "" || {(_key select [0, 1]) isEqualTo "#"}) exitWith {
        missionNamespace setVariable ["TC2_opord_statusText", "Kaydedilecek bir bölüm seçin."];
        call TC2_fnc_opordUiUpdate;
    };
    _args = [_key, parseNumber (_levelControl lbData (lbCurSel _levelControl)), ctrlText (_display displayCtrl 92604)];
};

if (_action in ["ACK", "SAVE", "TEMPLATE"]) then {
    private _call = [ACE_player, _terminal, call TC2_fnc_netGetRadioState, _action, _args];
    if (isServer) then {
        _call call TC2_fnc_opordEdit;
    } else {
        _call remoteExecCall ["TC2_fnc_opordEdit", 2];
    };
};
