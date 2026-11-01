/*
    Fonksiyon: TC2_fnc_opordEdit
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_opordEdit", 2]
                  - host / tek oyunculuda: opordUiAction doğrudan çağırır

    OPORD işlemleri. Doğrulamalar: gönderen, oturum (opordPoll ile aynı erişim kuralı).
      ACK       [] herhangi bir seviye: "OPORD'u aldım ve anladım" (kullanıcı başına, geçerli sürüm için). Onay sayısını Level 3 görür.
      SAVE      [bölüm anahtarı, yeni seviye 1-3, metin]  YALNIZCA Level 3. Sürümü artırır; ağdaki oturumlara "OPORD güncellendi" bilgi satırı gider.
      TEMPLATE  []  YALNIZCA Level 3, yalnızca belge YOKSA: boş beş paragraf şablonunu oluşturur.
    Yazma yetkisi accessLevel'e göredir: yalnızca MASA BAŞINDA Level 3 (Siyah-Altın kart ya da CO / S2 kadrosu). Saha cihazı en fazla Level 2'dir -> sahada düzenlenemez.
    Metin düz metindir (en çok 3000 karakter); kontrol karakterleri atılır (satır sonu kalır).

    Parametreler:
        0: birim <OBJECT>   1: terminal / saha cihazı <OBJECT>   2: telsiz durumu <ARRAY>
        3: işlem <STRING>   4: argümanlar <ARRAY>   5: belge türü <STRING> ("OPORD" | "WARNO"; varsayılan "OPORD")

    Dönüş: yok (yanıt: opordOnAck)
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]], ["_action", "", [""]], ["_args", [], [[]]], ["_docType", "OPORD", [""]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code"];

private _physical = _terminal isKindOf "TC2_Terminal_F";
private _allowed = _ok && {_code isEqualTo "OK" || {_physical && {_code in ["NO_RADIO", "NO_ACRE"]}}};
private _ack = {[_unit, "TC2_fnc_opordOnAck", _this] call TC2_fnc_netToUnit};

if (!_allowed) exitWith {[_code, []] call _ack};

private _level = [_unit, _terminal] call TC2_fnc_accessLevel;
private _variable = ["TC2_opord", "TC2_warno"] select (_docType isEqualTo "WARNO");
private _document = missionNamespace getVariable [_variable, []];

switch (_action) do {
    case "ACK": {
        if (_document isEqualTo []) exitWith {["EMPTY", []] call _ack};
        private _version = _document select 3;
        private _uid = getPlayerUID _unit;
        private _key = if (_uid isEqualTo "") then {name _unit} else {_uid};
        private _acks = _document select 6;
        if (count (_acks select {(_x select 0) isEqualTo _key && {(_x select 2) == _version}}) == 0) then {
            _acks pushBack [_key, name _unit, _version];
            diag_log format ["[TC2][OPORD] ONAY | %1 %2 | surum=%3 | seviye=%4", _docType, name _unit, _version, _level];
        };
        ["ACKED", [_version]] call _ack;
    };

    case "SAVE": {
        if (_level < 3) exitWith {
            diag_log format ["[TC2][OPORD] RED: duzenleme yetkisi yok (%1, seviye %2)", name _unit, _level];
            ["NOT_EDITOR", []] call _ack;
        };
        if (_document isEqualTo []) exitWith {["EMPTY", []] call _ack};

        _args params [["_key", "", [""]], ["_newLevel", 1, [0]], ["_text", "", [""]]];

        // Düz metin: satır sonu dışındaki kontrol karakterleri atılır, uzunluk sınırlanır.
        private _plain = toString ((toArray _text) select {_x == 10 || {_x >= 32}});
        _plain = _plain select [0, 3000 min count _plain];

        private _sections = _document select 5;
        private _index = -1;
        {
            if ((_x select 0) isEqualTo _key) exitWith {_index = _forEachIndex};
        } forEach _sections;

        if (_index < 0) exitWith {["NO_SECTION", []] call _ack};

        _sections set [_index, [_key, (_sections select _index) select 1, ((round _newLevel) max 1) min 3, _plain]];

        private _version = (_document select 3) + 1;
        _document set [3, _version];
        _document set [4, name _unit];

        diag_log format ["[TC2][OPORD] GUNCELLENDI | bolum=%1 | seviye=%2 | surum=%3 | duzenleyen=%4", _key, ((round _newLevel) max 1) min 3, _version, name _unit];
        [netId _unit, format ["%1 güncellendi (sürüm %2): bölüm %3", _docType, _version, _key]] call TC2_fnc_netInfo;

        ["SAVED", [_version]] call _ack;
    };

    case "TEMPLATE": {
        if (_level < 3) exitWith {["NOT_EDITOR", []] call _ack};
        if !(_document isEqualTo []) exitWith {["EXISTS", []] call _ack};

        private _date = date;
        private _dtg = format ["%1%2%3Z", _date select 2, _date select 3, _date select 4];
        private _created = [["OPERASYON EMRİ", "UYARI EMRİ"] select (_docType isEqualTo "WARNO"), _dtg, "TC2 EGITIM", [_docType] call TC2_fnc_opordTemplate, name _unit, _docType] call TC2_fnc_opordSet;
        diag_log format ["[TC2][OPORD] SABLON olusturuldu | %1", name _unit];
        [["NO_SECTION", "TEMPLATE_OK"] select _created, []] call _ack;
    };

    default {};
};
