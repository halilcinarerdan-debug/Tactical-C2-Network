/*
    Fonksiyon: TC2_fnc_uiWatch
    Çalışma yeri: İstemci (CBA PerFrameHandler, gecikme 1 sn; yalnızca terminal penceresi açıkken)

    Oturum geçerli mi? Erişim kontrolünün aynısı (accessCheck) yeniden sorulur: kart çekildi mi,
    5 m'den uzaklaşıldı mı, ölüm/bilinç kaybı, sistem devre dışı mı. Biri bozulduysa pencere kapanır.
    (Bu kontrol kolaylıktır; yetki kararı değildir. Gizli veri sunucudan gelecek, bkz. Aşama 6.)

    Aşama 3: aynı saniyelik döngü telsiz durumunu da izler (yeni döngü/PFH eklenmedi).

    Pencere zaten kapalıysa kendini kaldırır.

    Parametreler: CBA PFH standardı [[terminal], handle]
    Dönüş: yok
*/

params ["_args", "_handle"];
_args params ["_terminal"];

private _display = findDisplay 92000;
if (isNull _display) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
};

private _result = [_terminal, ACE_player] call TC2_fnc_accessCheck;

if !(_result select 0) exitWith {
    _display closeDisplay 2;
    [format ["Oturum sonlandırıldı. %1", [_result select 1] call TC2_fnc_accessReasonText], "info"] call TC2_fnc_notify;
};

// Ağ (Aşama 3): telsiz durumunu yerelde oku (ucuz); değiştiyse ya da 5 sn dolduysa sunucuya bildir.
// Sunucunun yanıtı (BAĞLANTI durumu) netOnStatus ile gelir; durum satırı yalnızca metin değişirse yazılır.
private _state = call TC2_fnc_netGetRadioState;
private _lastState = missionNamespace getVariable ["TC2_net_lastState", []];
private _lastReport = missionNamespace getVariable ["TC2_net_lastReport", -100];

if (!(_state isEqualTo _lastState) || {(diag_tickTime - _lastReport) > 5}) then {
    [_terminal, _state] call TC2_fnc_netReportState;
};

call TC2_fnc_netUiUpdate;

// HARİTA sekmesi açıksa veriyi 5 sn'de bir yenile (Aşama 4).
private _tick = (missionNamespace getVariable ["TC2_ui_tick", 0]) + 1;
missionNamespace setVariable ["TC2_ui_tick", _tick];
private _tab = missionNamespace getVariable ["TC2_ui_tab", 0];
if (_tick % 5 == 0) then {
    if (_tab == 1) then {call TC2_fnc_copUiRequest};
    if (_tab == 2) then {call TC2_fnc_casUiRequest};
    if (_tab in [3, 4]) then {call TC2_fnc_artyUiRequest};
};
