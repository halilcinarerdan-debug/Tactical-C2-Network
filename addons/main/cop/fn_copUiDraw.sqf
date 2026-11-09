/*
    Fonksiyon: TC2_fnc_copUiDraw
    Çalışma yeri: İstemci (terminal haritasının "Draw" olayı; yalnızca HARİTA sekmesi görünürken)

    Önbellekteki veriyi çizer: kendin (yeşil), ağdaki dostlar (mavi; liderler büyük ve etiketli; LACE varsa lider simgesi
    LACE durumuna göre boyanır), düşman işaretleri (kırmızı, tür + yaş), doğrulanmamış SALUTE noktaları (soru işaretli simge). Hesaplama yok, yalnızca drawIcon; önbellek copOnData ile
    5 sn'de bir yenilenir.

    Parametreler: Draw olayı [harita]
    Dönüş: yok
*/

params ["_map"];

private _font = ["PuristaMedium", "EtelkaMonospacePro"] select (missionNamespace getVariable ["TC2_ui_mono", true]);

// Oyun harita işaretleri (KATMAN): 5 sn'de bir hazırlanan önbellek; burada yalnızca çizim.
{
    _x params ["_shape", "_pos", "_texture", "_color", "_size", "_angle", "_text", "_extra"];
    switch (_shape) do {
        case "ICON": {
            _map drawIcon [_texture, _color, _pos, _size, _size, _angle, _text, 1, 0.04, _font, "right"];
        };
        case "ELLIPSE": {
            _map drawEllipse [_pos, _size select 0, _size select 1, _angle, _color, _extra select 0];
        };
        case "RECTANGLE": {
            _map drawRectangle [_pos, _size select 0, _size select 1, _angle, _color, _extra select 0];
        };
        case "POLYLINE": {
            {_map drawLine [_x select 0, _x select 1, _color]} forEach _extra;
        };
    };
} forEach (missionNamespace getVariable ["TC2_cop_gameMarkers", []]);

(missionNamespace getVariable ["TC2_cop_data", [[], [], []]]) params ["_friends", "_markers", ["_unverified", []], ["_ops", []]];

// Aktif operasyon noktaları (CAS hedefi / CFF hedefi / MEDEVAC alım yeri): oyunun askeri ve NATO simgeleriyle
{
    _x params ["_kind", "_id", "_pos", "_label"];
    private _icon = switch (_kind) do {
        case "CAS": {"\A3\ui_f\data\map\markers\military\destroy_CA.paa"};
        case "CFF": {"\A3\ui_f\data\map\markers\military\objective_CA.paa"};
        default {"\A3\ui_f\data\map\markers\nato\b_med.paa"};
    };
    private _color = switch (_kind) do {
        case "CAS": {[1, 0.5, 0.1, 1]};
        case "CFF": {[1, 0.85, 0.2, 1]};
        default {[0.3, 1, 0.5, 1]};
    };
    _map drawIcon [_icon, _color, _pos, 24, 24, 0, _label, 1, 0.045, _font, "right"];
} forEach _ops;

// Ok mesafesi: ekranda yaklaşık 0.035 birim (harita ölçeğinden metreye çevrilir; kare başına tek hesap).
private _arrowReach = (_map ctrlMapScreenToWorld [0.5, 0.5]) distance2D (_map ctrlMapScreenToWorld [0.535, 0.5]);

{
    _x params ["_pos", "_label", "_leader", "", ["_status", ""], ["_heading", -1]];
    private _color = switch (_status) do {
        case "GREEN": {[0.2, 0.85, 0.3, 1]};
        case "AMBER": {[1, 0.78, 0.1, 1]};
        case "RED":   {[1, 0.4, 0.05, 1]};
        case "BLACK": {[0.65, 0.65, 0.65, 1]};
        default {[0.1, 0.4, 1, 1]};
    };
    _map drawIcon [
        "\A3\ui_f\data\map\markers\nato\b_inf.paa", _color, _pos,
        [20, 28] select _leader, [20, 28] select _leader, 0,
        ["", [_label, format ["%1  [%2]", _label, _status]] select !(_status isEqualTo "")] select _leader, 1, 0.045, _font, "right"
    ];

    // Lider bakış oku: simgenin önünde, bakılan yönde (ok ile simge arası ekranda sabit uzaklık: haritayı yakınlaştırınca da aynı kalır).
    if (_leader && {_heading >= 0}) then {
        private _tip = [(_pos select 0) + (sin _heading) * _arrowReach, (_pos select 1) + (cos _heading) * _arrowReach, _pos select 2];
        _map drawIcon ["\A3\ui_f\data\map\markers\military\arrow_CA.paa", _color, _tip, 24, 24, _heading, "", 0];
    };
} forEach _friends;

{
    _x params ["_id", "_pos", "_age"];
    _map drawIcon [
        "\A3\ui_f\data\map\markers\nato\o_unknown.paa", [1, 0.65, 0.2, 1], _pos,
        26, 26, 0,
        format ["SALUTE #%1 ? %2 dk", _id, floor (_age / 60)], 1, 0.045, _font, "right"
    ];
} forEach _unverified;

{
    _x params ["", "_type", "_pos", "", "_age"];
    ([_type] call TC2_fnc_copTypeInfo) params ["", "_icon", "_iconSize", "_iconColor"];
    _map drawIcon [
        _icon, _iconColor, _pos,
        _iconSize, _iconSize, 0,
        format ["%1  %2 dk", [_type] call TC2_fnc_copTypeName, floor (_age / 60)], 1, 0.045, _font, "right"
    ];
} forEach _markers;

_map drawIcon [
    "\A3\ui_f\data\map\markers\nato\b_inf.paa", [0.25, 1, 0.35, 1], getPosASL ACE_player,
    28, 28, getDir ACE_player, "SEN", 1, 0.045, _font, "right"
];

// ÖLÇ: A noktası seçiliyse çizgi B'ye (ya da B yoksa imlece) uzanır.
private _measure = missionNamespace getVariable ["TC2_cop_measure", []];
if !(_measure isEqualTo []) then {
    private _from = _measure select 0;
    private _to = if (count _measure > 1) then {_measure select 1} else {missionNamespace getVariable ["TC2_cop_cursor", []]};

    _map drawIcon ["\A3\ui_f\data\map\markers\military\dot_CA.paa", [1, 0.9, 0.3, 1], _from, 14, 14, 0, "A", 1, 0.045, _font, "right"];
    if !(_to isEqualTo []) then {
        _map drawLine [_from, _to, [1, 0.9, 0.3, 1]];
        if (count _measure > 1) then {
            _map drawIcon ["\A3\ui_f\data\map\markers\military\dot_CA.paa", [1, 0.9, 0.3, 1], _to, 14, 14, 0, format ["B  %1 m", round (_from distance2D _to)], 1, 0.045, _font, "right"];
        };
    };
};
