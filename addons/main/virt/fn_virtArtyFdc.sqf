/*
    Fonksiyon: TC2_fnc_virtArtyFdc
    Çalışma yeri: SADECE SUNUCU (artySendCff, "SANAL FDC" alıcı seçildiyse zamanlayıcıyla çağırır)

    Sanal FDC: CFF'yi gerçek bir FDC gibi KABUL eder (sanal batarya açıksa). Sanal batarya kapalıysa CFF reddedilir.

    Parametreler:
        0: görev id <NUMBER>

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_id", -1, [0]]];

private _index = [_id] call TC2_fnc_artyMissionIndex;
if (_index < 0) exitWith {};

private _mission = (missionNamespace getVariable ["TC2_arty_missions", []]) select _index;
if !((_mission select 7) isEqualTo "REQUEST") exitWith {};

if !(missionNamespace getVariable ["TC2_virt_arty", false]) exitWith {
    _mission set [7, "REJECTED"];
    [_id, "CFF REDDEDİLDİ: sanal topçu kapalı.", "BAD"] call TC2_fnc_artyEvent;
};

[_id, 0, "", "SANAL FDC"] call TC2_fnc_virtArtyAccept;
