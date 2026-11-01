/*
    Fonksiyon: TC2_fnc_artyNearestFriendly
    Çalışma yeri: SADECE SUNUCU (saf)

    Bir noktaya en yakın DOST oyuncu / telsiz taşıyıcısının 2B mesafesi (metre). Danger close denetimi için
    (ATP 3-09.30, 4-35: hedef dost birliklerin 600 m içindeyse DANGER CLOSE bildirilmelidir).
    Bakılanlar: tüm oyuncular + saha varlığı kaydındaki (telsizi olan) birimler, verilen tarafın canlı üyeleri. Gözlemcinin kendisi de sayılır.

    Parametreler:
        0: konum <ARRAY>
        1: taraf <SIDE>

    Dönüş: [mesafe m <NUMBER>, ad <STRING>]  (dost yoksa [99999, ""])
*/

params [["_pos", [0, 0, 0], [[]]], ["_side", west, [west]]];

private _candidates = allPlayers + ((missionNamespace getVariable ["TC2_cop_field", []]) apply {_x select 1});
private _best = 99999;
private _name = "";

{
    if (!isNull _x && {alive _x} && {(side (group _x)) isEqualTo _side}) then {
        private _distance = (getPosASL _x) distance2D _pos;
        if (_distance < _best) then {
            _best = _distance;
            _name = name _x;
        };
    };
} forEach _candidates;

[_best, _name]
