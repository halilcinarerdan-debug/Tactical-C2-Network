/*
    Fonksiyon: TC2_fnc_artyUiChanged
    Çalışma yeri: İstemci (görev türü ve konum yöntemi değişince)

    Konum yöntemine göre alan etiketlerini ve görünürlüğünü ayarlar (ATP 3-09.30, 4-19..4-29):
      GRID  : yalnızca HEDEF / NOKTA (HARİTA sekmesindeki işaret; konum ve yükseklik oradan)
      POLAR : F1 yön (mil), F2 mesafe (m), F3 dikey kayma (m, + yukarı)
      SHIFT : HEDEF / NOKTA = bilinen nokta (işaret ya da önceki hedef no), F1 yön (mil), F2 sol(-)/sağ(+) m, F3 drop(-)/add(+) m, F4 down(-)/up(+) m
    IMMEDIATE görevlerde kontrol FIRE WHEN READY'e kilitlenir (tek aktarım; AT MY COMMAND yok). SUPPRESS'te süre (DURATION) etkindir.
    Sadece TOPÇU sekmesi ve panel A görünürken görünürlük ayarlanır.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

private _method = _display displayCtrl 92402;
private _type = _display displayCtrl 92401;
if (isNull _method || {isNull _type}) exitWith {};

private _methodKey = _method lbData (lbCurSel _method);
private _typeKey = _type lbData (lbCurSel _type);

private _spec = switch (_methodKey) do {
    case "POLAR": {[false, ["YÖN (mil)", "MESAFE (m)", "DİKEY (m)", ""], [true, true, true, false]]};
    case "SHIFT": {[true, ["YÖN (mil)", "SOL(-) / SAĞ(+) m", "DROP(-) / ADD(+) m", "DOWN(-) / UP(+) m"], [true, true, true, true]]};
    default {[true, ["", "", "", ""], [false, false, false, false]]};
};
_spec params ["_showRef", "_labels", "_showField"];

private _panelA = (missionNamespace getVariable ["TC2_arty_panelA", true]) && {(missionNamespace getVariable ["TC2_ui_tab", 0]) == 3};

(_display displayCtrl 92503) ctrlSetText (["", "HEDEF / NOKTA"] select _showRef);
(_display displayCtrl 92408) ctrlShow (_panelA && _showRef);
(_display displayCtrl 92503) ctrlShow (_panelA && _showRef);

{
    (_display displayCtrl (92504 + _forEachIndex)) ctrlSetText (_labels select _forEachIndex);
    (_display displayCtrl (92504 + _forEachIndex)) ctrlShow (_panelA && (_showField select _forEachIndex));
    (_display displayCtrl (92403 + _forEachIndex)) ctrlShow (_panelA && (_showField select _forEachIndex));
} forEach _labels;

private _control = _display displayCtrl 92417;
if (_typeKey in ["IMM_SUPP", "IMM_SMOKE"]) then {
    _control lbSetCurSel 0;
    _control ctrlEnable false;
} else {
    _control ctrlEnable true;
};

(_display displayCtrl 92418) ctrlEnable (_typeKey isEqualTo "SUPPRESS");
