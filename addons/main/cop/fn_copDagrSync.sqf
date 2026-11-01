/*
    Fonksiyon: TC2_fnc_copDagrSync
    Çalışma yeri: İSTEMCİ (sunucu, yalnızca MicroDAGR'lı GRUP LİDERLERİNE gönderir)

    Düşman işaretlerini ACE MicroDAGR cihazına waypoint olarak yazar ("TC2 #5 INF 024057" gibi: işaret no, tür kodu, grid). DAGR, waypoint'leri
    kendi haritasında çizer ve yön/mesafe gösterir. Normal Arma haritasında GÖRÜNMEZ.

    Yalnızca adı "TC2 " ile başlayan waypoint'lere dokunulur; oyuncunun kendi waypoint'leri korunur (başta, sıraları değişmez).
    Oyuncu bir TC2 waypoint'ini hedef seçmişse seçim, işaretlerin listesi değişince adıyla yeniden eşlenir.
    ACE sürümü değişirse değişken adları (aşağıda) kontrol edilmelidir.

    Parametreler:
        0: işaretler <ARRAY>  [[id, tür, konum ASL]]  (boş dizi = TC2 waypoint'lerini temizle)

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_markers", [], [[]]]];

// ACE MicroDAGR (kaynak: ACE3 addons/microdagr): waypoint'ler ACE_player üzerinde `ace_microdagr_waypoints` = [[ad, konum ASL]]; cihaz her karede bunu
// doğrudan okur (önbellek yok). Genel API yalnızca ace_microdagr_fnc_deviceAddWaypoint'tir (ekler); silme/değiştirme API'si genel değildir,
// bu yüzden değişkene doğrudan yazılır. Seçili hedef waypoint dizini ise `ace_microdagr_currentWaypoint` (-1 = hedef yok, -2 = telemetre hedefi).
private _key = "ace_microdagr_waypoints";
private _old = ACE_player getVariable [_key, []];

// Oyuncu şu an bir TC2 waypoint'ini hedef seçtiyse adını hatırla (liste değişince dizin kaysın ya da sınır dışı kalmasın).
private _current = missionNamespace getVariable ["ace_microdagr_currentWaypoint", -1];
private _currentName = "";
if (_current >= 0 && {_current < count _old}) then {
    private _name = (_old select _current) select 0;
    if ((_name find "TC2 ") == 0) then {_currentName = _name};
};

private _waypoints = _old select {!(((_x select 0) find "TC2 ") == 0)};
{
    _x params ["_id", "_type", "_pos"];
    _waypoints pushBack [format ["TC2 #%1 %2 %3", _id, _type, mapGridPosition _pos], _pos];
} forEach _markers;

ACE_player setVariable [_key, _waypoints];

if !(_currentName isEqualTo "") then {
    // Oyuncunun kendi waypoint'leri başta ve yerinde kaldığı için yalnızca TC2 hedefi yeniden eşlenir; silindiyse hedef kalkar.
    missionNamespace setVariable ["ace_microdagr_currentWaypoint", (_waypoints apply {_x select 0}) find _currentName];
};

private _previous = missionNamespace getVariable ["TC2_cop_dagrCount", 0];
if ((count _markers) > _previous) then {
    ["MicroDAGR: yeni düşman işareti.", "info"] call TC2_fnc_notify;
};
missionNamespace setVariable ["TC2_cop_dagrCount", count _markers];
