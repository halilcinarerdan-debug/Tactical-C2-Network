/*
    Fonksiyon: TC2_fnc_opordPoll
    Çalışma yeri: SADECE SUNUCU
                  - uzak istemciden: remoteExecCall ["TC2_fnc_opordPoll", 2]
                  - host / tek oyunculuda: opordUiRequest doğrudan çağırır

    OPORD sekmesinin verisi. GİZLİLİK SUNUCUDA UYGULANIR: kullanıcının seviyesinden (userLevel) yüksek seviyeli bölümlerin METNİ istemciye
    HİÇ GÖNDERİLMEZ; yalnızca başlık ve gereken seviye ("GİZLİ - Level N") gider. İstemci kurcalansa bile gizli metin makinede bulunmaz.
    Erişim: fiziksel terminalde telsiz GEREKMEZ (belge üstedir); saha cihazında telsiz ağı gerekir.

    Yanıt (opordOnData): [kod, seviye, [başlık, DTG, etiket, sürüm, yayımlayan], görünür bölümler, gizli bölümler, onay sayısı, kendi onayım var mı]

    Parametreler:
        0: birim <OBJECT>
        1: terminal / saha cihazı <OBJECT>
        2: telsiz durumu <ARRAY>

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]], ["_state", [], [[]]]];

if (isNull _unit) exitWith {};
if !([_unit] call TC2_fnc_netSenderOk) exitWith {};

private _session = [_unit, _terminal, _state] call TC2_fnc_netServerSession;
_session params ["_ok", "_code"];

private _physical = _terminal isKindOf "TC2_Terminal_F";
private _allowed = _ok && {_code isEqualTo "OK" || {_physical && {_code in ["NO_RADIO", "NO_ACRE"]}}};

if (!_allowed) exitWith {
    [_unit, "TC2_fnc_opordOnData", [_code, 1, [], [], [], 0, false]] call TC2_fnc_netToUnit;
};

private _document = missionNamespace getVariable ["TC2_opord", []];
private _level = [_unit] call TC2_fnc_userLevel;

if (_document isEqualTo []) exitWith {
    [_unit, "TC2_fnc_opordOnData", ["EMPTY", _level, [], [], [], 0, false]] call TC2_fnc_netToUnit;
};

_document params ["_title", "_dtg", "_classification", "_version", "_issuer", "_sections", "_acks"];

private _visible = _sections select {(_x select 2) <= _level};
private _hidden = (_sections select {(_x select 2) > _level}) apply {[_x select 0, _x select 1, _x select 2]};

private _uid = getPlayerUID _unit;
private _key = if (_uid isEqualTo "") then {name _unit} else {_uid};
private _current = _acks select {(_x select 2) == _version};
private _mine = count (_current select {(_x select 0) isEqualTo _key}) > 0;

[_unit, "TC2_fnc_opordOnData", ["OK", _level, [_title, _dtg, _classification, _version, _issuer], _visible, _hidden, count _current, _mine]] call TC2_fnc_netToUnit;
