/*
    Fonksiyon: TC2_fnc_virtShell
    Çalışma yeri: SADECE SUNUCU

    Sanal bataryanın bir mermisini hedefe düşürür: hedef noktasının üstünde (HE: ~900 m, duman: ~250 m, aydınlatma: ~450 m) mermi nesnesi oluşturulur ve
    aşağı hız verilir; oyunun kendi patlama / duman / flare etkisi çalışır. Sapma (yayılım) rastgele dairesel dağılımdır.

    Parametreler:
        0: hedef konum <ARRAY>  (ASL)
        1: mermi sınıfı <STRING>  (CfgAmmo)
        2: sapma yarıçapı <NUMBER>  (m)

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_aim", [0, 0, 0], [[]]], ["_class", "", [""]], ["_error", 25, [0]]];

if (_class isEqualTo "") exitWith {};

private _radius = _error * (sqrt (random 1));
private _angle = random 360;
private _x = (_aim select 0) + _radius * (sin _angle);
private _y = (_aim select 1) + _radius * (cos _angle);
private _ground = getTerrainHeightASL [_x, _y];

private _name = toLower _class;
private _height = 900;
private _speed = -260;
if ((_name find "smoke") >= 0) then {_height = 250; _speed = -150};
if ((_name find "flare") >= 0 || {(_name find "illum") >= 0}) then {_height = 450; _speed = -25};

private _shell = createVehicle [_class, [_x, _y, 200], [], 0, "CAN_COLLIDE"];
_shell setPosASL [_x, _y, _ground + _height];
_shell setVectorDirAndUp [[0, 0, -1], [0, 1, 0]];
_shell setVelocity [0, 0, _speed];
