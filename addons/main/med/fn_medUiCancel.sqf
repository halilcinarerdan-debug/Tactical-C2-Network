/*
    Fonksiyon: TC2_fnc_medUiCancel
    Çalışma yeri: İSTEMCİ (TALEBİ İPTAL ET düğmesi; yetki sunucuda yeniden denetlenir: yalnızca talebi gönderen)

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

private _inbox = _display displayCtrl 92800;
private _id = parseNumber (_inbox lbData (lbCurSel _inbox));
if (_id <= 0) exitWith {};

if (isServer) then {
    [ACE_player, _id] call TC2_fnc_medCancel;
} else {
    [ACE_player, _id] remoteExecCall ["TC2_fnc_medCancel", 2];
};
