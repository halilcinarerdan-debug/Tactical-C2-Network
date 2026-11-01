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

// Sekme numarası, TOPÇU/FDC görünürlüğü hesaplanmadan ÖNCE kaydedilir.
missionNamespace setVariable ["TC2_ui_tab", _index];

{
    private _button = _display displayCtrl (92010 + _forEachIndex);
    _button ctrlSetBackgroundColor (if (_forEachIndex == _index) then {[0.1, 0.45, 0.15, 1]} else {[0.02, 0.1, 0.03, 1]});
} forEach (missionNamespace getVariable ["TC2_ui_tabs", []]);

// Ağ paneli (92030-92034) yalnızca ANA sekmesinde.
{
    (_display displayCtrl _x) ctrlShow (_index == 0);
} forEach [92030, 92031, 92032, 92033, 92034];

// HARİTA sekmesi (92040-92043) yalnızca HARİTA'da. Seçilince veriyi hemen iste.
{
    (_display displayCtrl _x) ctrlShow (_index == 1);
} forEach [92040, 92041, 92042, 92043];

if (_index == 1) then {
    missionNamespace setVariable ["TC2_cop_mode", ""];
    call TC2_fnc_copUiMode;
    call TC2_fnc_copUiRequest;
};

// CAS sekmesi (9-Line formu) yalnızca CAS'ta. Seçilince veriyi hemen iste.
{
    (_display displayCtrl _x) ctrlShow (_index == 2);
} forEach (missionNamespace getVariable ["TC2_cas_ctrlIds", []]);

if (_index == 2) then {
    missionNamespace setVariable ["TC2_cas_statusText", ""];
    call TC2_fnc_casUiRequest;
    call TC2_fnc_casUiUpdate;
};

// TOPÇU (3) ve FDC (4) sekmeleri: görünürlük artyUiUpdate'te; seçilince veriyi hemen iste.
call TC2_fnc_artyUiUpdate;
if (_index in [3, 4]) then {
    missionNamespace setVariable ["TC2_arty_statusText", ""];
    call TC2_fnc_artyUiRequest;
};

private _terminal = missionNamespace getVariable ["TC2_terminal_current", objNull];

(_display displayCtrl 92020) ctrlSetStructuredText ([_index, _terminal, ACE_player] call TC2_fnc_uiTabText);

missionNamespace setVariable ["TC2_ui_tab", _index];
