/*
    Fonksiyon: TC2_fnc_virtCasWeapons
    Çalışma yeri: SADECE SUNUCU (saf)

    Uçağın silahlarını sınıflandırır (silah sınıf adına göre; vanilla ve çoğu mod adlandırması): top ("gatling" / "cannon" / "gun"), roket ("rocket"),
    bomba ("bomb"), hava-yer füzesi ("missile", hava-hava "_aa_" / "aam" hariç).

    Parametreler:
        0: uçak <OBJECT>

    Dönüş: [top, roket, bomba, füze] <ARRAY of STRING>  (yoksa "")
*/

params [["_plane", objNull, [objNull]]];

private _gun = "";
private _rocket = "";
private _bomb = "";
private _missile = "";

{
    private _name = toLower _x;
    if ((_name find "flare") >= 0 || {(_name find "chaff") >= 0} || {(_name find "laserdesignator") >= 0} || {(_name find "smokelauncher") >= 0}) then {continue};

    if ((_name find "missile") >= 0) then {
        if ((_name find "_aa_") < 0 && {(_name find "aam") < 0} && {(_name find "asraam") < 0} && {_missile isEqualTo ""}) then {_missile = _x};
    } else {
        if ((_name find "rocket") >= 0) then {
            if (_rocket isEqualTo "") then {_rocket = _x};
        } else {
            if ((_name find "bomb") >= 0) then {
                if (_bomb isEqualTo "") then {_bomb = _x};
            } else {
                if (((_name find "gatling") >= 0 || {(_name find "cannon") >= 0} || {(_name find "gun") >= 0}) && {_gun isEqualTo ""}) then {_gun = _x};
            };
        };
    };
} forEach (weapons _plane);

[_gun, _rocket, _bomb, _missile]
