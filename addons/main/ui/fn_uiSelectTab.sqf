/*
    Fonksiyon: TC2_fnc_uiSelectTab
    Çalışma yeri: İstemci (sekme düğmesi olayı / uiOpen)

    Seçili sekmeyi vurgular ve içerik alanını o sekmenin metniyle doldurur. Döngü yok, tek seferlik iş.

    Parametreler:
        0: sekme sırası <NUMBER>  (0 = ANA ... 5 = UAV)

    Dönüş: yok
*/

params [["_index", 0, [0]]];

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

{
    private _button = _display displayCtrl (92010 + _forEachIndex);
    _button ctrlSetBackgroundColor (if (_forEachIndex == _index) then {[0.1, 0.45, 0.15, 1]} else {[0.02, 0.1, 0.03, 1]});
} forEach (missionNamespace getVariable ["TC2_ui_tabs", []]);

// Ağ paneli (92030-92034) yalnızca ANA sekmesinde.
{
    (_display displayCtrl _x) ctrlShow (_index == 0);
} forEach [92030, 92031, 92032, 92033, 92034];

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];

(_display displayCtrl 92020) ctrlSetStructuredText ([_index, _terminal, ACE_player] call TC2_fnc_uiTabText);

missionNamespace setVariable ["TC2_ui_tab", _index];
