/*
    Fonksiyon: TC2_fnc_accessRequest
    Çalışma yeri: İSTEMCİ (ACE menüsü eylemi çağırır; scheduled DEĞİL, unscheduled)

    Terminale giriş talebini başlatır. Akış:

      İSTEMCİ                                   SUNUCU
      1. ön kontrol: kart var mı?  (UX: kartı olmayan 2 sn beklemesin)
         yoksa -> hata mesajı, BİTTİ
      2. "Kimlik doğrulanıyor" ilerleme çubuğu
      3. remoteExecCall ------------------->   4. accessServerHandle: göndereni doğrula,
                                                  accessCheck ile KARAR VER, RPT'ye kayıt düş
      6. accessResult  <------------------     5. sonucu istemciye gönder
         onay -> terminalOpen, ret -> hata mesajı

    Araç / helikopter içinde de çalışır: ilerleme çubuğuna ACE "araç içinde değil" koşulu muafiyeti verilir (aksi halde çubuk hemen iptal olurdu).

    Ön kontrol yetki değildir, yalnızca kolaylıktır. Asıl karar adım 4'te, sunucuda verilir.

    Talep numarası (reqId): aynı anda tek talep (TC2_access_pendingId). Yanıt eşleşmezse (eski talep /
    zaman aşımından sonra gelen yanıt) yok sayılır. Sunucu 8 sn içinde yanıt vermezse (örn. sunucuda
    mod yok) talep zaman aşımına uğrar ve menü tekrar kullanılabilir olur.

    Parametreler:
        0: terminal <OBJECT>
        1: oyuncu birimi <OBJECT>

    Dönüş: yok
*/

params [["_terminal", objNull, [objNull]], ["_player", objNull, [objNull]]];

if (isNull _terminal || {isNull _player}) exitWith {};

// Zaten yanıt bekleyen bir talep var.
if ((missionNamespace getVariable ["TC2_access_pendingId", -1]) >= 0) exitWith {};

// 1) Hızlı ön kontrol (yetki kararı DEĞİL)
// (Saha cihazı modunda terminal = birimin kendisi; kart yalnızca TC2_field_requireCard açıksa gerekir.)
private _fieldMode = _terminal isEqualTo _player;
private _needsCard = !_fieldMode || {missionNamespace getVariable ["TC2_field_requireCard", false]};

if (_needsCard && {!([_player] call TC2_fnc_accessHasCard)}) exitWith {
    [["NO_CARD"] call TC2_fnc_accessReasonText, "error"] call TC2_fnc_notify;
};

// 2) Talep numarası ver ve "beklemede" işaretle
private _reqId = (missionNamespace getVariable ["TC2_access_reqCounter", 0]) + 1;
missionNamespace setVariable ["TC2_access_reqCounter", _reqId];
missionNamespace setVariable ["TC2_access_pendingId", _reqId];

// 3) İlerleme çubuğu bitince talebi sunucuya gönder. (Kod bloğu dış değişken yakalamaz; her şey args ile gelir.)
private _onFinish = {
    params ["_args"];
    _args params ["_terminal", "_player", "_reqId"];

    if (isServer) then {
        // Host / tek oyunculu: sunucu bizim makinemiz, ağa gerek yok.
        [_terminal, _player, _reqId] call TC2_fnc_accessServerHandle;
    } else {
        // Uzak istemci: yalnızca sunucuya (CfgRemoteExec: allowedTargets = 2).
        [_terminal, _player, _reqId] remoteExecCall ["TC2_fnc_accessServerHandle", 2];
    };

    // Zaman aşımı: yanıt gelmezse talebi bırak.
    [{
        params ["_reqId"];
        if ((missionNamespace getVariable ["TC2_access_pendingId", -1]) == _reqId) then {
            missionNamespace setVariable ["TC2_access_pendingId", -1];
            [["TIMEOUT"] call TC2_fnc_accessReasonText, "error"] call TC2_fnc_notify;
        };
    }, [_reqId], 8] call CBA_fnc_waitAndExecute;
};

private _onFail = {
    // ACE ilerleme çubuğu hata kodu: 1 çubuk kapandı (başka pencere), 2 birim değişti / öldü, 3 mesafe, 4 ACE etkileşim koşulu (ör. harita açık, Zeus)
    params ["", "", "", ["_errorCode", -1]];
    missionNamespace setVariable ["TC2_access_pendingId", -1];
    diag_log format ["[TC2][ACCESS] istemci: ilerleme cubugu iptal | kod=%1", _errorCode];
    [format ["Kimlik doğrulama iptal edildi (kod %1: %2).", _errorCode, switch (_errorCode) do {
        case 1: {"başka bir pencere çubuğu kapattı"};
        case 2: {"birim değişti / öldü"};
        case 3: {"cihaz uzaklaştı"};
        case 4: {"ACE etkileşim koşulu (harita açık / Zeus / bayılma)"};
        default {"bilinmiyor"};
    }], "info"] call TC2_fnc_notify;
};

private _authTime = missionNamespace getVariable ["TC2_access_authTime", 2];

// Araç / helikopter içinde ilerleme çubuğu ATLANIR: ACE çubuğu araç içindeyken ve diğer ACE etkileşim koşullarında beklenmedik şekilde iptal olabiliyor.
// Yetki kararı zaten sunucudadır; çubuk yalnızca görsel bir bekleme süresidir.
if (_authTime <= 0 || {!isNull objectParent _player}) then {
    [[_terminal, _player, _reqId]] call _onFinish;
} else {
    [
        _authTime,
        [_terminal, _player, _reqId],
        _onFinish,
        _onFail,
        ["Kimlik doğrulanıyor...", "Saha cihazı bağlanıyor..."] select _fieldMode,
        {
            // Her karede çalışır: terminal hâlâ yakın mı?
            params ["_args"];
            _args params ["_terminal", "_player"];
            !isNull _terminal && {(_player distance _terminal) < 4}
        },
        // ACE ilerleme çubuğu, varsayılan olarak araç içindeyken (isNotInside) hemen iptal olur. Saha cihazı araç / helikopter içinde de
        // kullanılabilmeli; bu yüzden "araç içinde değil" koşulu ve benzer duruş koşulları bu çubuk için yok sayılır.
        ["isNotInside", "isNotSitting", "isNotSwimming", "isNotOnLadder", "isNotRefueling"]
    ] call ace_common_fnc_progressBar;
};
