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

(missionNamespace getVariable ["TC2_cop_data", [[], [], []]]) params ["_friends", "_markers", ["_unverified", []]];

{
    _x params ["_pos", "_label", "_leader", "", ["_status", ""]];
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
        ["", [_label, format ["%1  [%2]", _label, _status]] select !(_status isEqualTo "")] select _leader, 1, 0.045, "PuristaMedium", "right"
    ];
} forEach _friends;

{
    _x params ["_id", "_pos", "_age"];
    _map drawIcon [
        "\A3\ui_f\data\map\markers\nato\o_unknown.paa", [1, 0.65, 0.2, 1], _pos,
        26, 26, 0,
        format ["SALUTE #%1 ? %2 dk", _id, floor (_age / 60)], 1, 0.045, "PuristaMedium", "right"
    ];
} forEach _unverified;

{
    _x params ["", "_type", "_pos", "", "_age"];
    _map drawIcon [
        "\A3\ui_f\data\map\markers\nato\o_inf.paa", [1, 0.1, 0.1, 1], _pos,
        26, 26, 0,
        format ["%1  %2 dk", [_type] call TC2_fnc_copTypeName, floor (_age / 60)], 1, 0.045, "PuristaMedium", "right"
    ];
} forEach _markers;

_map drawIcon [
    "\A3\ui_f\data\map\markers\nato\b_inf.paa", [0.25, 1, 0.35, 1], getPosASL ACE_player,
    28, 28, getDir ACE_player, "SEN", 1, 0.045, "PuristaMedium", "right"
];
