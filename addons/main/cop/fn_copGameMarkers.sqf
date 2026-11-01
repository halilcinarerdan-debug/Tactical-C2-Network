/*
    Fonksiyon: TC2_fnc_copGameMarkers
    Çalışma yeri: İstemci (copOnData / KATMAN düğmesi; harita verisi her yenilendiğinde, yani 5 sn'de bir)

    Oyuncunun KENDİ oyun haritasında gördüğü harita işaretlerini (Eden / Zeus / oyuncu işaretleri; allMapMarkers) terminal haritası için
    önbelleğe alır. Semboller ve renkler oyunun kendi CfgMarkers / CfgMarkerColors tanımlarından gelir. Yeni bilgi sızdırmaz: oyuncu bunları
    zaten kendi haritasında görür. TC2 düşman işaretleri oyun işareti DEĞİLDİR (yalnızca terminalde çizilir).
    Çizim hesapsızdır; bu fonksiyon çizimden ayrı, seyrek çalışır. Üst sınır: 150 işaret, 400 çizgi parçası.

    Önbellek girişleri: [şekil, konum, doku, renk, boyut, açı, metin, ek]
      ICON: ek = []   ELLIPSE / RECTANGLE: boyut = [a, b] metre, ek = [dolgu dokusu]   POLYLINE: ek = [[[x1,y1],[x2,y2]], ...] parçalar

    Parametreler: yok
    Dönüş: yok
*/

if (!hasInterface) exitWith {};
if !(missionNamespace getVariable ["TC2_cop_layer", true]) exitWith {};

private _toColor = {
    params ["_raw"];
    private _color = _raw apply {if (_x isEqualType "") then {call compile _x} else {_x}};
    if (count _color < 4) then {_color = [1, 1, 1, 1]};
    _color
};

private _cache = [];
private _segmentBudget = 400;

{
    private _name = _x;
    private _type = markerType _name;
    private _shape = markerShape _name;
    private _alpha = markerAlpha _name;
    private _pos = markerPos _name;

    if (_alpha > 0 && {count _cache < 150} && {!(_type isEqualTo "Empty")} && {!(_pos isEqualTo [0, 0, 0]) || {_shape isEqualTo "POLYLINE"}}) then {
        private _colorName = markerColor _name;
        private _color = if (_colorName in ["", "Default"]) then {
            [getArray (configFile >> "CfgMarkers" >> _type >> "color")] call _toColor
        } else {
            [getArray (configFile >> "CfgMarkerColors" >> _colorName >> "color")] call _toColor
        };
        _color set [3, (_color select 3) * _alpha];

        if (_shape isEqualTo "ICON") then {
            private _texture = getText (configFile >> "CfgMarkers" >> _type >> "icon");
            if !(_texture isEqualTo "") then {
                private _scale = (markerSize _name) select 0;
                _cache pushBack ["ICON", _pos, _texture, _color, ((getNumber (configFile >> "CfgMarkers" >> _type >> "size")) max 16) * (_scale max 0.5), markerDir _name, markerText _name, []];
            };
        };
        if (_shape in ["ELLIPSE", "RECTANGLE"]) then {
            private _fill = getText (configFile >> "CfgMarkerBrushes" >> (markerBrush _name) >> "texture");
            _cache pushBack [_shape, _pos, "", _color, markerSize _name, markerDir _name, markerText _name, [_fill]];
        };
        if (_shape isEqualTo "POLYLINE") then {
            private _points = markerPolyline _name;
            private _segments = [];
            for "_i" from 0 to ((count _points) - 4) step 2 do {
                if (_segmentBudget > 0) then {
                    _segments pushBack [[_points select _i, _points select (_i + 1)], [_points select (_i + 2), _points select (_i + 3)]];
                    _segmentBudget = _segmentBudget - 1;
                };
            };
            if !(_segments isEqualTo []) then {_cache pushBack ["POLYLINE", [0, 0, 0], "", _color, [0, 0], 0, "", _segments]};
        };
    };
} forEach allMapMarkers;

missionNamespace setVariable ["TC2_cop_gameMarkers", _cache];
