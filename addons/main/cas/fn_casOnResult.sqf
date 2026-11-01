/*
    Fonksiyon: TC2_fnc_casOnResult
    Çalışma yeri: İSTEMCİ (JTAC ve pilot; sunucu geri okuma sonucunu / iptali gönderir)

    Pilot tarafında saklanan talebin durum ve sonuçlarını günceller; JTAC tarafında etkin talebin özetini günceller.
    Kısa bildirim gösterir.

    Parametreler:
        0: talep id <NUMBER>
        1: durum <STRING>  "READBACK_OK" | "READBACK_FAIL" | "ABORTED"
        2: sonuçlar <ARRAY>

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_id", -1, [0]], ["_state", "", [""]], ["_results", [], [[]]]];

// Pilot: gelen talebi güncelle
private _incoming = missionNamespace getVariable ["TC2_cas_incoming", []];
if (count _incoming > 0 && {(_incoming select 0) == _id}) then {
    _incoming set [5, _state];
    if (_state isEqualTo "ABORTED") then {
        // iptal: eski sonuçlar kalır
    } else {
        _incoming set [6, _results];
    };
};

// JTAC: etkin talep özetini güncelle
private _data = missionNamespace getVariable ["TC2_cas_data", [false, [], []]];
private _summary = _data select 2;
if (count _summary > 0 && {(_summary select 0) == _id}) then {
    _summary set [1, _state];
    if !(_state isEqualTo "ABORTED") then {_summary set [3, _results]};
};

private _message = switch (_state) do {
    case "READBACK_OK":   {["GERİ OKUMA DOĞRU", "success"]};
    case "READBACK_FAIL": {["GERİ OKUMA YANLIŞ", "error"]};
    case "ABORTED":       {["CAS TALEBİ İPTAL EDİLDİ", "error"]};
    default {["", "info"]};
};
if !((_message select 0) isEqualTo "") then {_message call TC2_fnc_notify};

// Durum satırı yeni durumdan (özet) türetilsin: eski "Gönderiliyor..." gibi metni temizle.
missionNamespace setVariable ["TC2_cas_statusText", ""];

call TC2_fnc_casUiUpdate;
call TC2_fnc_casPilotUpdate;
