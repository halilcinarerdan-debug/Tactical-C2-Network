/*
    Fonksiyon: TC2_fnc_copAiLeaders
    Çalışma yeri: SADECE SUNUCU (saf; 5 sn önbellekli)

    Haritada gösterilecek AI GRUP LİDERLERİ: oyuncu olmayan, canlı, grubunun lideri olan ve envanterinde saha tableti (CBA "Saha cihazı eşyası")
    taşıyan birimler. Tablet şartı oyunculardakiyle AYNIDIR (eşya boşsa şart yok), ancak AI hava aracı muafiyeti uygulanmaz:
    görev tasarımcısı bir AI lideri haritaya `this addItem "TC2_Tablet"` ile açar. Ayar TC2_cop_showAi kapalıysa boş döner.
    Tarama saniyede çok kez çağrılabileceği için sonuç 5 sn önbelleğe alınır.

    Parametreler: yok
    Dönüş: [[birim, taraf]] <ARRAY>
*/

if (!(missionNamespace getVariable ["TC2_cop_showAi", true])) exitWith {[]};

private _cache = missionNamespace getVariable ["TC2_cop_aiCache", [-100, []]];
if ((diag_tickTime - (_cache select 0)) < 5) exitWith {_cache select 1};

private _item = toLower (missionNamespace getVariable ["TC2_field_deviceItem", "TC2_Tablet"]);

private _list = (allUnits select {
    !isPlayer _x && {alive _x} && {(leader (group _x)) isEqualTo _x}
    && {_item isEqualTo "" || {_item in ((items _x + assignedItems _x) apply {toLower _x})}}
}) apply {[_x, side (group _x)]};

missionNamespace setVariable ["TC2_cop_aiCache", [diag_tickTime, _list]];

_list
