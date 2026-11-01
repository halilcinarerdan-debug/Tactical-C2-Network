/*
    Fonksiyon: TC2_fnc_artyResolvePos
    Çalışma yeri: SADECE SUNUCU (saf: yalnızca okur)

    CFF'teki konum yöntemini dünya konumuna (ASL) çevirir (ATP 3-09.30, 4-19..4-29):
      GRID  -> gönderilen konum.
      POLAR -> gözlemci konumundan yön (mil) + mesafe (m) + dikey kayma.
      SHIFT -> bilinen noktadan (HARİTA işareti "M<id>" ya da önceki hedef numarası "T<AF####>") yön + sol/sağ + add/drop + up/down.
    Bilinen nokta GÖZLEMCİNİN GÖREBİLDİĞİ işaretlerden olmalıdır (aynı ağ + menzil). Çözülemezse [] döner.

    Parametreler:
        0: form verisi <ARRAY>
        1: gözlemci birimi <OBJECT>
        2: telsiz tipi <STRING>
        3: kanal <NUMBER>

    Dönüş: konum ASL <ARRAY> ([] = çözülemedi)
*/

params [["_data", [], [[]]], ["_unit", objNull, [objNull]], ["_base", "", [""]], ["_channel", -1, [0]]];

if (count _data != 15 || {isNull _unit}) exitWith {[]};

_data params ["", "_method", "_grid", "_polar", "_shift"];

private _result = [];

if (_method isEqualTo "GRID") then {
    _result = _grid;
};

if (_method isEqualTo "POLAR") then {
    _polar params ["_dirMils", "_distance", "_vertical"];
    private _azimuth = [_dirMils] call TC2_fnc_artyMilsToDeg;
    private _origin = getPosASL _unit;
    _result = [
        (_origin select 0) + _distance * (sin _azimuth),
        (_origin select 1) + _distance * (cos _azimuth),
        (_origin select 2) + _vertical
    ];
};

if (_method isEqualTo "SHIFT") then {
    _shift params ["_reference", "_dirMils", "_right", "_add", "_up"];
    private _kind = _reference select [0, 1];
    private _key = _reference select [1, (count _reference) - 1];
    private _basePos = [];

    if (_kind isEqualTo "M") then {
        private _id = parseNumber _key;
        {
            if ((_x select 0) == _id) exitWith {_basePos = _x select 2};
        } forEach ([_base, _channel, _unit] call TC2_fnc_copMarkersFor);
    };

    if (_kind isEqualTo "T") then {
        {
            if ((_x select 0) isEqualTo _key) exitWith {_basePos = _x select 1};
        } forEach (missionNamespace getVariable ["TC2_arty_targets", []]);
    };

    if !(_basePos isEqualTo []) then {
        _result = [_basePos, _dirMils, _right, _add, _up] call TC2_fnc_artyCorrect;
    };
};

_result
