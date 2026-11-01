/*
    Fonksiyon: TC2_fnc_uiWatch
    Çalışma yeri: İstemci (CBA PerFrameHandler, gecikme 1 sn; yalnızca terminal penceresi açıkken)

    Oturum geçerli mi? Erişim kontrolünün aynısı (accessCheck) yeniden sorulur: kart çekildi mi,
    5 m'den uzaklaşıldı mı, ölüm/bilinç kaybı, sistem devre dışı mı. Biri bozulduysa pencere kapanır.
    (Bu kontrol kolaylıktır; yetki kararı değildir. Gizli veri sunucudan gelecek, bkz. Aşama 6.)

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

if !(_result select 0) then {
    _display closeDisplay 2;
    [format ["Oturum sonlandırıldı. %1", [_result select 1] call TC2_fnc_accessReasonText], "info"] call TC2_fnc_notify;
};
