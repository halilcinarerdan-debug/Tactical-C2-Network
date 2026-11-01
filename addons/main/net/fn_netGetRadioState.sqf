/*
    Fonksiyon: TC2_fnc_netGetRadioState
    Çalışma yeri: İSTEMCİ (ACRE2 API'si yalnızca yerel oyuncuyu sorgular; sunucu başkasının telsizini okuyamaz)

    Oyuncunun AKTİF ACRE2 telsizini okur. ACRE2 yüklü değilse ya da aktif telsiz yoksa "telsiz yok" döner.
    ACRE2'ye yumuşak bağımlılık: acre_api_fnc_* tanımlı değilse hata vermez.

    Kullanılan ACRE2 genel API'si: getCurrentRadio, getBaseRadio, getRadioChannel.

    Parametreler: yok

    Dönüş: [telsiz var mı <BOOL>, telsiz ID <STRING>, taban sınıf <STRING>, kanal <NUMBER>, neden <STRING>]
        neden: "OK" | "NO_RADIO" | "NO_ACRE"
*/

if (isNil "acre_api_fnc_getCurrentRadio") exitWith {[false, "", "", -1, "NO_ACRE"]};

private _radio = [] call acre_api_fnc_getCurrentRadio;

if (isNil "_radio" || {!(_radio isEqualType "")} || {_radio isEqualTo ""}) exitWith {[false, "", "", -1, "NO_RADIO"]};

private _base = [_radio] call acre_api_fnc_getBaseRadio;
private _channel = [_radio] call acre_api_fnc_getRadioChannel;

if (isNil "_base" || {isNil "_channel"}) exitWith {[false, "", "", -1, "NO_RADIO"]};

[true, _radio, _base, _channel, "OK"]
