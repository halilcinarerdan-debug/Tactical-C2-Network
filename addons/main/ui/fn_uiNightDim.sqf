/*
    Fonksiyon: TC2_fnc_uiNightDim
    Çalışma yeri: İstemci (uiOpen ve uiWatch; saniyede en çok 1 kez)

    Gece modu: gece (güneş/ay ışığı düşük) ya da gece görüş (NVG/termal) açıkken terminal ekranına yarı saydam siyah örtü koyar (parlaklık kısma);
    gündüz örtü tamamen saydamdır. Gerçek saha cihazlarının "gece parlaklığı" davranışıdır; arayüzde ek düğme yoktur.
    CBA "TC2_ui_nightDim" kapalıysa hiçbir şey yapmaz.

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

private _overlay = _display displayCtrl 92090;
if (isNull _overlay) exitWith {};

private _night = (missionNamespace getVariable ["TC2_ui_nightDim", true]) && {(sunOrMoon < 0.25) || {(currentVisionMode ACE_player) > 0}};
_overlay ctrlSetBackgroundColor [0, 0, 0, [0, 0.4] select _night];
