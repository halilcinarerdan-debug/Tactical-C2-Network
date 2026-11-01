/*
    Fonksiyon: TC2_fnc_copDagrSync
    Çalışma yeri: İSTEMCİ (sunucu, yalnızca MicroDAGR'lı GRUP LİDERLERİNE gönderir)

    Düşman işaretlerini ACE MicroDAGR cihazına waypoint olarak yazar ("TC2 INF 123456" gibi). DAGR, waypoint'leri
    kendi haritasında çizer ve yön/mesafe gösterir. Normal Arma haritasında GÖRÜNMEZ.

    ACE MicroDAGR cihazı, waypoint'leri oyuncu objesinde `ace_microdagr_waypoints` değişkeninde tutar
    ([[ad, konum ASL]]). Yalnızca adı "TC2 " ile başlayanlara dokunulur; oyuncunun kendi waypoint'leri korunur.
    Not: bu değişken ACE'in genel API'si değildir (genel olan yalnızca deviceAddWaypoint); ACE sürümü değişirse
    buradaki biçim kontrol edilmelidir.

    Parametreler:
        0: işaretler <ARRAY>  [[id, tür, konum ASL]]  (boş dizi = TC2 waypoint'lerini temizle)

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_markers", [], [[]]]];

private _key = "ace_microdagr_waypoints";
private _waypoints = (ACE_player getVariable [_key, []]) select {!(((_x select 0) find "TC2 ") == 0)};

{
    _x params ["", "_type", "_pos"];
    _waypoints pushBack [format ["TC2 %1 %2", _type, mapGridPosition _pos], _pos];
} forEach _markers;

ACE_player setVariable [_key, _waypoints];

private _previous = missionNamespace getVariable ["TC2_cop_dagrCount", 0];
if ((count _markers) > _previous) then {
    ["MicroDAGR: yeni düşman işareti.", "info"] call TC2_fnc_notify;
};
missionNamespace setVariable ["TC2_cop_dagrCount", count _markers];
