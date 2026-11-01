/*
    Fonksiyon: TC2_fnc_uiOpen
    Çalışma yeri: İSTEMCİ (terminalOpen çağırır; yalnızca sunucu erişimi ONAYLADIKTAN sonra)

    Terminal penceresini açar. Tasarım ilkeleri: basit, düz, hızlı.
      - Boş diyalog (TC2_TerminalDialog) + kontroller scriptte ctrlCreate ile kurulur (config'te UI sınıfı yok).
      - Kare başına çalışan UI kodu YOK. Sekme değişimi düğme olayıyla, otomatik kapanma kontrolü
        saniyede 1 kez (uiWatch) çalışır ve pencere kapanınca kendini kaldırır.
      - Pencere ekranın ortasında, genişlik/yükseklik %70. Modal diyalog: karakter yerinde durur, oyun akar.

    Düzen:
        [ başlık: TC2 KOMUTA TERMİNALİ | terminal | kullanıcı ................ [KAPAT] ]
        [ ANA | HARİTA | CAS | TOPÇU | FDC | OPORD | İSTİHBARAT | LOJİSTİK | UAV ]
        [ içerik (sekmeye göre)                                                        ]
        [ alt satır: ESC = kapat                                                       ]

    Kapatma: KAPAT düğmesi, ESC, ya da otomatik (uiWatch: kart çekildi, 5 m'den uzaklaşıldı,
    ölüm/bilinç kaybı, sistem devre dışı).

    Parametreler:
        0: terminal <OBJECT>
        1: oyuncu birimi <OBJECT>

    Dönüş: yok
*/

params [["_terminal", objNull, [objNull]], ["_player", objNull, [objNull]]];

if (isNull _terminal) exitWith {};
if (!isNull findDisplay 92000) exitWith {};

// ACE ilerleme çubuğu kendi diyaloğunu bu karede kapatmış olabilir; yenisini bir sonraki karede aç.
[{
    params ["_terminal", "_player"];

    if (!isNull findDisplay 92000) exitWith {};
    if (!createDialog "TC2_TerminalDialog") exitWith {
        diag_log "[TC2][UI] createDialog TC2_TerminalDialog basarisiz.";
    };

    private _display = findDisplay 92000;
    if (isNull _display) exitWith {};

    missionNamespace setVariable ["TC2_terminal_current", _terminal];

    private _tabs = ["ANA", "HARİTA", "CAS", "TOPÇU", "FDC", "OPORD", "İSTİHBARAT", "LOJİSTİK", "UAV"];
    missionNamespace setVariable ["TC2_ui_tabs", _tabs];

    private _w = 0.7 * safeZoneW;
    private _h = 0.7 * safeZoneH;
    private _left = safeZoneX + (safeZoneW - _w) / 2;
    private _top = safeZoneY + (safeZoneH - _h) / 2;

    private _headerH = 0.05;
    private _tabH = 0.05;
    private _footerH = 0.04;
    private _pad = 0.015;
    private _closeW = 0.14;

    private _green = [0.25, 1, 0.35, 1];

    // Arka plan
    private _background = _display ctrlCreate ["RscText", 92001];
    _background ctrlSetPosition [_left, _top, _w, _h];
    _background ctrlSetBackgroundColor [0, 0.04, 0, 0.95];
    _background ctrlCommit 0;

    // Başlık
    private _header = _display ctrlCreate ["RscText", 92002];
    _header ctrlSetPosition [_left, _top, _w - _closeW, _headerH];
    _header ctrlSetBackgroundColor [0, 0.2, 0.05, 1];
    _header ctrlSetTextColor _green;
    _header ctrlSetText format [
        "  %1   |   %2   |   %3",
        ["TC2 KOMUTA TERMİNALİ", "TC2 SAHA CİHAZI"] select (_terminal isKindOf "CAManBase"),
        [_terminal] call TC2_fnc_terminalGetId,
        name _player
    ];
    _header ctrlCommit 0;

    // Kapat düğmesi
    private _closeButton = _display ctrlCreate ["RscButtonMenu", 92003];
    _closeButton ctrlSetPosition [_left + _w - _closeW, _top, _closeW, _headerH];
    _closeButton ctrlSetText "KAPAT";
    _closeButton ctrlSetBackgroundColor [0.45, 0.05, 0.05, 1];
    _closeButton ctrlSetTextColor [1, 1, 1, 1];
    _closeButton ctrlAddEventHandler ["ButtonClick", {
        (ctrlParent (_this select 0)) closeDisplay 2;
    }];
    _closeButton ctrlCommit 0;

    // Sekme düğmeleri (IDC 92010 + sıra)
    private _tabW = _w / count _tabs;
    {
        private _tabButton = _display ctrlCreate ["RscButtonMenu", 92010 + _forEachIndex];
        _tabButton ctrlSetPosition [_left + _forEachIndex * _tabW, _top + _headerH, _tabW, _tabH];
        _tabButton ctrlSetText _x;
        _tabButton ctrlSetFontHeight 0.03;
        _tabButton ctrlSetTextColor _green;
        _tabButton ctrlAddEventHandler ["ButtonClick", {
            [(ctrlIDC (_this select 0)) - 92010] call TC2_fnc_uiSelectTab;
        }];
        _tabButton ctrlCommit 0;
    } forEach _tabs;

    // İçerik alanı
    private _contentY = _top + _headerH + _tabH + _pad;
    private _content = _display ctrlCreate ["RscStructuredText", 92020];
    _content ctrlSetPosition [_left + _pad, _contentY, _w - 2 * _pad, _h - (_headerH + _tabH + _footerH + 3 * _pad)];
    _content ctrlSetBackgroundColor [0, 0, 0, 0];
    _content ctrlCommit 0;

    // Ağ paneli (Aşama 3): yalnızca ANA sekmesinde görünür. IDC: 92030 durum, 92031 mesaj kutusu,
    // 92032 GÖNDER, 92033 PING, 92034 günlük. ANA bilgi bloğunun (4 satır) altına yerleşir.
    private _contentH = _h - (_headerH + _tabH + _footerH + 3 * _pad);
    private _netTop = _contentY + 0.22;
    private _rowH = 0.04;
    private _inputTop = _netTop + _rowH + 0.01;
    private _inputH = 0.045;
    private _buttonW = 0.13;
    private _gap = 0.01;
    private _logTop = _inputTop + _inputH + 0.01;

    private _netStatus = _display ctrlCreate ["RscText", 92030];
    _netStatus ctrlSetPosition [_left + _pad, _netTop, _w - 2 * _pad, _rowH];
    _netStatus ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
    _netStatus ctrlCommit 0;

    private _edit = _display ctrlCreate ["RscEdit", 92031];
    _edit ctrlSetPosition [_left + _pad, _inputTop, _w - 2 * _pad - 2 * (_buttonW + _gap), _inputH];
    _edit ctrlSetBackgroundColor [0, 0.08, 0.02, 1];
    _edit ctrlSetTextColor _green;
    _edit ctrlAddEventHandler ["KeyDown", {
        params ["", "_key"];
        if (_key in [28, 156]) exitWith {
            call TC2_fnc_netUiSend;
            true
        };
        false
    }];
    _edit ctrlCommit 0;

    private _sendButton = _display ctrlCreate ["RscButtonMenu", 92032];
    _sendButton ctrlSetPosition [_left + _w - _pad - 2 * _buttonW - _gap, _inputTop, _buttonW, _inputH];
    _sendButton ctrlSetText "GÖNDER";
    _sendButton ctrlSetTextColor _green;
    _sendButton ctrlSetBackgroundColor [0.1, 0.45, 0.15, 1];
    _sendButton ctrlAddEventHandler ["ButtonClick", {call TC2_fnc_netUiSend}];
    _sendButton ctrlCommit 0;

    private _pingButton = _display ctrlCreate ["RscButtonMenu", 92033];
    _pingButton ctrlSetPosition [_left + _w - _pad - _buttonW, _inputTop, _buttonW, _inputH];
    _pingButton ctrlSetText "PING";
    _pingButton ctrlSetTextColor _green;
    _pingButton ctrlSetBackgroundColor [0.02, 0.1, 0.03, 1];
    _pingButton ctrlAddEventHandler ["ButtonClick", {["PING"] call TC2_fnc_netSend}];
    _pingButton ctrlCommit 0;

    private _netLog = _display ctrlCreate ["RscStructuredText", 92034];
    _netLog ctrlSetPosition [_left + _pad, _logTop, _w - 2 * _pad, (_contentY + _contentH) - _logTop];
    _netLog ctrlSetBackgroundColor [0, 0, 0, 0];
    _netLog ctrlCommit 0;

    // HARİTA sekmesi (Aşama 4): harita + işaret düğmeleri; varsayılan gizli.
    [_display, _left + _pad, _contentY, _w - 2 * _pad, _contentH] call TC2_fnc_copUiBuild;

    // CAS sekmesi (Aşama 5): tek ekranlı 9-Line formu; varsayılan gizli.
    [_display, _left + _pad, _contentY, _w - 2 * _pad, _contentH] call TC2_fnc_casUiBuild;

    // TOPÇU (gözlemci) ve FDC sekmeleri (Aşama 5B); varsayılan gizli.
    [_display, _left + _pad, _contentY, _w - 2 * _pad, _contentH] call TC2_fnc_artyObsBuild;
    [_display, _left + _pad, _contentY, _w - 2 * _pad, _contentH] call TC2_fnc_artyFdcBuild;
    missionNamespace setVariable ["TC2_arty_data", [false, false, [], [], [], [], []]];
    missionNamespace setVariable ["TC2_arty_code", "OK"];
    {missionNamespace setVariable [_x, ""]} forEach ["TC2_arty_infoText", "TC2_arty_logText", "TC2_arty_detailText", "TC2_arty_fdcLogText", "TC2_arty_batteryText"];

    // OPORD sekmesi (Aşama 6): yetki seviyeli belge; varsayılan gizli.
    [_display, _left + _pad, _contentY, _w - 2 * _pad, _contentH] call TC2_fnc_opordBuild;
    missionNamespace setVariable ["TC2_opord_data", ["EMPTY", 1, [], [], [], 0, false]];
    {missionNamespace setVariable [_x, ""]} forEach ["TC2_opord_infoText"];
    missionNamespace setVariable ["TC2_opord_viewText", "\n"];

    // Ağ durumunu sıfırla (yeni oturum) ve sunucuya ilk raporu gönder.
    missionNamespace setVariable ["TC2_net_status", []];
    missionNamespace setVariable ["TC2_net_statusTime", diag_tickTime];
    missionNamespace setVariable ["TC2_net_statusText", "\n"];
    missionNamespace setVariable ["TC2_net_logText", "\n"];
    missionNamespace setVariable ["TC2_net_log", []];
    missionNamespace setVariable ["TC2_net_nextSend", 0];

    // Alt satır
    private _footer = _display ctrlCreate ["RscText", 92021];
    _footer ctrlSetPosition [_left, _top + _h - _footerH, _w, _footerH];
    _footer ctrlSetBackgroundColor [0, 0.12, 0.03, 1];
    _footer ctrlSetTextColor [0.12, 0.6, 0.2, 1];
    _footer ctrlSetText "  ESC = kapat";
    _footer ctrlCommit 0;

    // ESC (DIK = 1): duraklatma menüsü açılmasın, pencere kapansın.
    _display displayAddEventHandler ["KeyDown", {
        params ["_display", "_key"];
        if (_key == 1) exitWith {
            _display closeDisplay 2;
            true
        };
        false
    }];

    // Yazı kutusu dışına sol tık: klavye odağını kutudan al (bkz. uiReleaseFocus).
    _display displayAddEventHandler ["MouseButtonDown", {
        params ["_display", "_button", "_mx", "_my"];
        if (_button != 0) exitWith {};
        [
            _display, _mx, _my,
            [92031, 92203, 92204, 92206, 92207, 92208, 92211, 92212, 92214, 92215, 92216, 92217, 92218, 92219, 92403, 92404, 92405, 92406, 92409, 92416, 92418, 92430, 92431, 92432, 92433, 92440, 92453, 92454, 92457, 92604],
            92010 + (missionNamespace getVariable ["TC2_ui_tab", 0])
        ] call TC2_fnc_uiReleaseFocus;
    }];

    _display displayAddEventHandler ["Unload", {
        call TC2_fnc_uiOnUnload;
    }];

    // Otomatik kapanma kontrolü: saniyede 1 kez, yalnızca pencere açıkken.
    private _handle = [TC2_fnc_uiWatch, 1, [_terminal]] call CBA_fnc_addPerFrameHandler;
    missionNamespace setVariable ["TC2_ui_watchHandle", _handle];

    [0] call TC2_fnc_uiSelectTab;

    [_terminal, call TC2_fnc_netGetRadioState] call TC2_fnc_netReportState;
    call TC2_fnc_netUiUpdate;

    // Sonraki aşamalar bu olaya bağlanabilir.
    ["TC2_terminalOpened", [_terminal, _player]] call CBA_fnc_localEvent;
}, [_terminal, _player]] call CBA_fnc_execNextFrame;
