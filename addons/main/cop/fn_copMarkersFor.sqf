/*
    Fonksiyon: TC2_fnc_copMarkersFor
    Çalışma yeri: SADECE SUNUCU

    Bir izleyicinin görebildiği düşman işaretlerini verir. Önce süresi dolanları siler (TTL).
    Görünürlük kuralı: işaret AĞA aittir (telsiz tipi + kanal). İzleyici aynı ağdaysa VE işareti koyan birimin
    telsiz menzili içindeyse görür (koyan hâlâ ağdaysa güncel konumuna, değilse işareti koyduğu andaki konumuna göre).

    İşaret kaydı: 0 id   1 tür   2 konum ASL   3 telsiz tipi   4 kanal   5 koyan etiketi   6 koyan netId
                  7 oluşma zamanı (diag_tickTime)   8 koyanın konumu (koyduğu an, ASL)

    Parametreler:
        0: telsiz tipi <STRING>
        1: kanal <NUMBER>
        2: izleyici birim <OBJECT>

    Dönüş: işaret kayıtları <ARRAY of ARRAY>
*/

params [["_base", "", [""]], ["_channel", -1, [0]], ["_viewer", objNull, [objNull]]];

private _now = diag_tickTime;
private _ttl = (missionNamespace getVariable ["TC2_cop_markerTtl", 30]) * 60;

private _all = (missionNamespace getVariable ["TC2_cop_markers", []]) select {(_now - (_x select 7)) < _ttl};
missionNamespace setVariable ["TC2_cop_markers", _all];

if (_base isEqualTo "" || {isNull _viewer}) exitWith {[]};

private _range = [_base] call TC2_fnc_netRangeOf;
private _field = missionNamespace getVariable ["TC2_cop_field", []];
private _viewerPos = getPosASL _viewer;

_all select {
    ((_x select 3) isEqualTo _base) && {(_x select 4) == _channel} && {
        private _authorNet = _x select 6;
        private _reference = _x select 8;
        {
            if ((_x select 0) isEqualTo _authorNet && {alive (_x select 1)}) exitWith {_reference = getPosASL (_x select 1)};
        } forEach _field;
        (_viewerPos distance _reference) <= _range
    }
}
