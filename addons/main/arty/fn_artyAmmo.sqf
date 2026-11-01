/*
    Fonksiyon: TC2_fnc_artyAmmo
    Çalışma yeri: SADECE SUNUCU (saf)

    İstenen mühimmat türü (HE | SMOKE | WP | ILLUM) için araçların taşıdığı UYGUN şarjör sınıfını seçer.
    Sınıflandırma şarjör adından yapılır (vanilla ve ACE adlandırması): "smoke" -> SMOKE, "flare"/"illum" -> ILLUM, "wp"/"phosph" -> WP;
    "guided", "lg", "laser", "cluster", "mine", "dpicm" gibi özel mühimmat HE sayılmaz; kalan alışılmış mermiler HE'dir.

    Parametreler:
        0: araçlar <ARRAY of OBJECT>  (aynı bataryanın topları)
        1: mühimmat türü <STRING>

    Dönüş: şarjör sınıfı <STRING> ("" = yok)
*/

params [["_vehicles", [], [[]]], ["_projectile", "HE", [""]]];

if (_vehicles isEqualTo []) exitWith {""};

private _classify = {
    private _name = toLower _this;
    if ((_name find "smoke") >= 0) exitWith {"SMOKE"};
    if ((_name find "flare") >= 0 || {(_name find "illum") >= 0}) exitWith {"ILLUM"};
    if ((_name find "_wp") >= 0 || {(_name find "phosph") >= 0}) exitWith {"WP"};
    if ((_name find "guided") >= 0 || {(_name find "_lg") >= 0} || {(_name find "laser") >= 0} || {(_name find "cluster") >= 0} || {(_name find "mine") >= 0} || {(_name find "dpicm") >= 0}) exitWith {"SPECIAL"};
    "HE"
};

private _chosen = "";
{
    if ((_x call _classify) isEqualTo _projectile) exitWith {_chosen = _x};
} forEach (getArtilleryAmmo _vehicles);

_chosen
