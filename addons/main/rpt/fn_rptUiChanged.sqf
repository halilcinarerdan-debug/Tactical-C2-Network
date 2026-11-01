/*
    Fonksiyon: TC2_fnc_rptUiChanged
    Çalışma yeri: İstemci (tür listesi olayı)

    Rapor türü değişince form etiketlerini ve alan düzenini ayarlar, ardından sekmeyi günceller.
      SALUTE: S, A, L (konum listesi), U, T, E        SITREP: 6 serbest metin alanı (faaliyet/ilerleme, düşman, düşman KIA, güvenlik duruşu, ikmal talebi, notlar)        LACE: 4 durum listesi + not alanı

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display || {isNull (_display displayCtrl 92700)}) exitWith {};

private _combo = _display displayCtrl 92700;
private _type = _combo lbData (lbCurSel _combo);
if (_type isEqualTo "") then {_type = "SALUTE"};
missionNamespace setVariable ["TC2_rpt_type", _type];

private _labels = switch (_type) do {
    case "SALUTE": {["S  Size", "A  Activity", "L  Location", "U  Unit", "T  Time", "E  Equipment"]};
    case "SITREP": {["Faaliyet", "Düşman", "Düşman KIA", "Güvenlik", "İkmal talebi", "Notlar"]};
    default {["L  Liquid", "A  Ammunition", "C  Casualties", "E  Equipment", "", ""]};
};
{
    (_display displayCtrl (92740 + _forEachIndex)) ctrlSetText _x;
} forEach _labels;

// LACE'te metin alanları durum listesinin yanına kayar.
private _positions = missionNamespace getVariable ["TC2_rpt_pos", []];
{
    private _control = _display displayCtrl (92720 + _forEachIndex);
    private _p = +_x;
    if (_type isEqualTo "LACE") then {
        _p set [0, (_p select 0) + 0.205];
        _p set [2, (_p select 2) - 0.205];
    };
    _control ctrlSetPosition _p;
    _control ctrlCommit 0;
} forEach _positions;

call TC2_fnc_rptUiUpdate;
