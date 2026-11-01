/*
    Fonksiyon: TC2_fnc_netUiUpdate
    Çalışma yeri: İstemci

    Ağ panelini günceller: durum satırı (92030) ve günlük (92034). Pencere kapalıysa hiçbir şey yapmaz.
    Durum satırı yalnızca metin değiştiyse yeniden yazılır (uiWatch bunu saniyede 1 çağırır, ucuzdur).

    Durum satırı kuralları (sunucunun kararı):
        LINK      -> "BAĞLANTI VAR | N terminal menzilde | TELSİZ Kn"          (yeşil)
        NO_PEERS  -> "BAĞLANTI YOK | menzilde terminal yok | TELSİZ Kn"         (kırmızı)
        NO_RADIO  -> "BAĞLANTI YOK | aktif telsiz yok"                          (kırmızı)
        NO_ACRE   -> "BAĞLANTI YOK | ACRE2 yüklü değil"                         (kırmızı)
        durum yok / 15 sn güncellenmedi -> bekleniyor / sunucu yanıt vermiyor    (sarı)

    Parametreler: yok
    Dönüş: yok
*/

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

private _status = missionNamespace getVariable ["TC2_net_status", []];
private _age = diag_tickTime - (missionNamespace getVariable ["TC2_net_statusTime", diag_tickTime]);

private _text = "";
private _color = [1, 0.35, 0.35, 1];

if (_status isEqualTo []) then {
    _text = "  AĞ: sunucudan durum bekleniyor...";
    _color = [1, 0.8, 0.2, 1];
    if (_age > 15) then {_text = "  AĞ: SUNUCU YANIT VERMİYOR (sunucuda mod yüklü mü?)"};
} else {
    _status params ["_code", "_count", "_base", "_channel"];

    private _shortBase = if ((_base find "ACRE_") == 0) then {_base select [5, (count _base) - 5]} else {_base};
    private _radio = format ["%1 K%2", _shortBase, _channel];

    switch (_code) do {
        case "LINK": {
            _text = format ["  BAĞLANTI VAR   |   %1 terminal menzilde   |   %2", _count, _radio];
            _color = [0.25, 1, 0.35, 1];
        };
        case "NO_PEERS": {_text = format ["  BAĞLANTI YOK   |   menzilde terminal yok   |   %1", _radio]};
        case "NO_RADIO": {_text = "  BAĞLANTI YOK   |   aktif telsiz yok"};
        case "NO_ACRE":  {_text = "  BAĞLANTI YOK   |   ACRE2 yüklü değil"};
        default {_text = format ["  AĞ: %1", [_code] call TC2_fnc_accessReasonText]};
    };

    if (_age > 15) then {
        _text = "  AĞ: SUNUCU YANIT VERMİYOR (durum eski)";
        _color = [1, 0.8, 0.2, 1];
    };
};

if !(_text isEqualTo (missionNamespace getVariable ["TC2_net_statusText", ""])) then {
    missionNamespace setVariable ["TC2_net_statusText", _text];
    private _statusControl = _display displayCtrl 92030;
    _statusControl ctrlSetText _text;
    _statusControl ctrlSetTextColor _color;
};

private _logText = (missionNamespace getVariable ["TC2_net_log", []]) joinString "<br/>";
if !(_logText isEqualTo (missionNamespace getVariable ["TC2_net_logText", "\n"])) then {
    missionNamespace setVariable ["TC2_net_logText", _logText];
    (_display displayCtrl 92034) ctrlSetStructuredText parseText format ["<t size='0.9'>%1</t>", _logText];
};
