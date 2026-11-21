/*
    Fonksiyon: TC2_fnc_virtCasRun
    Çalışma yeri: SADECE SUNUCU

    Sanal CAS uçağını oluşturur ve atak koşusunu başlatır. Uçak, 9-Line'daki saldırı yönünden (satır 15 FAH, yoksa satır 3) hedefe ~7 km geriden girer;
    uçuşu betikle (hız + yön) yönetilir, silahları uçağın KENDİ silahlarıdır (fireAtTarget): top, roket, bomba, füze. Hedef türüne göre sıra:
      araç / zırh sözcüğü varsa (satır 7): füze -> bomba -> roket -> top;  aksi halde: roket -> top (+ bomba).
    Lazer işaretlemede (satır 9 LASER) hedefe lazer hedef nesnesi konur (güdümlü silahlar için). Talep iptal edilirse (ABORT) uçak ateş etmeden çıkar.
    Sortiden sonra uçak ve mürettebat silinir; tarafın sanal CAS'ı yeniden dolum süresi kadar meşgul kalır.

    Parametreler:
        0: talep id <NUMBER>

    Dönüş: yok
*/

if (!isServer) exitWith {};

params [["_id", -1, [0]]];

private _index = [_id] call TC2_fnc_casReqIndex;
if (_index < 0) exitWith {};

private _request = (missionNamespace getVariable ["TC2_cas_requests", []]) select _index;
private _side = side (group (_request select 2));
private _sideKey = str _side;
private _jtacNet = _request select 1;
private _data = _request select 5;

private _finish = {
    params ["_sideKey"];
    missionNamespace setVariable [format ["TC2_virt_casBusy_%1", _sideKey], false];
    missionNamespace setVariable [format ["TC2_virt_casReady_%1", _sideKey], diag_tickTime + (missionNamespace getVariable ["TC2_virt_casCooldown", 120])];
};

if ((_request select 7) isEqualTo "ABORTED") exitWith {
    [_jtacNet, format ["SANAL CAS #%1: talep iptal edildi, uçak çevrildi (ABORT).", _id]] call TC2_fnc_netInfo;
    [_sideKey] call _finish;
};

private _class = switch (_side) do {
    case west: {missionNamespace getVariable ["TC2_virt_casClassWest", "B_Plane_CAS_01_dynamicLoadout_F"]};
    case east: {missionNamespace getVariable ["TC2_virt_casClassEast", "O_Plane_CAS_02_dynamicLoadout_F"]};
    default {missionNamespace getVariable ["TC2_virt_casClassGuer", "I_Plane_Fighter_03_dynamicLoadout_F"]};
};

if !(isClass (configFile >> "CfgVehicles" >> _class)) exitWith {
    [_jtacNet, format ["SANAL CAS #%1: uçak sınıfı yok (%2); CBA ayarını kontrol edin.", _id, _class]] call TC2_fnc_netInfo;
    diag_log format ["[TC2][VIRT] CAS ucak sinifi yok: %1", _class];
    [_sideKey] call _finish;
};

// hedef ve saldırı yönü
private _targetPos = _data select 8;
private _target2D = [_targetPos select 0, _targetPos select 1];
private _groundZ = getTerrainHeightASL _target2D;
private _heading = if ((_data select 15) >= 0) then {_data select 15} else {_data select 3};
private _dirH = [sin _heading, cos _heading, 0];

// uçak: hedefin 7 km gerisinde, ~800 m yükseklikte, atak yönüne bakar
private _spawn2D = _target2D vectorAdd (_dirH vectorMultiply -7000);
private _spawnZ = (getTerrainHeightASL _spawn2D) max _groundZ;
private _plane = createVehicle [_class, [_spawn2D select 0, _spawn2D select 1, 800], [], 0, "FLY"];
_plane setPosASL [_spawn2D select 0, _spawn2D select 1, _spawnZ + 800];
_plane setDir _heading;
_plane setVelocity (_dirH vectorMultiply 200);
_plane allowDamage false;
createVehicleCrew _plane;
// Yapay zekâ uçağı kendisi uçurmasın (uçuşu betik yönetir); silahlar fireAtTarget ile açık komutla ateşlenir.
{
    private _member = _x;
    _member allowDamage false;
    {_member disableAI _x} forEach ["MOVE", "PATH", "AUTOCOMBAT", "SUPPRESSION", "COVER"];
} forEach (crew _plane);
_plane engineOn true;

// hedef nesnesi: lazer işaretlemede lazer hedefi (güdümlü silahlar), aksi halde görünmez küre
private _laserClass = switch (_side) do {case west: {"LaserTargetW"}; case east: {"LaserTargetE"}; default {"LaserTargetC"}};
private _targetClass = if ((_data select 9) isEqualTo "LASER" && {isClass (configFile >> "CfgVehicles" >> _laserClass)}) then {_laserClass} else {"Sign_Sphere10cm_F"};
private _targetObject = createVehicle [_targetClass, [_target2D select 0, _target2D select 1, 0], [], 0, "CAN_COLLIDE"];
_targetObject setPosASL [_target2D select 0, _target2D select 1, _groundZ + 0.5];
if (_targetClass isEqualTo "Sign_Sphere10cm_F") then {hideObjectGlobal _targetObject};

private _weapons = [_plane] call TC2_fnc_virtCasWeapons;
_weapons params ["_gun", "_rocket", "_bomb", "_missile"];

private _description = toLower (_data select 7);
private _vehicleTarget = false;
{
    if ((_description find _x) >= 0) exitWith {_vehicleTarget = true};
} forEach ["tank", "zırh", "zirh", "araç", "arac", "apc", "bmp", "btr", "mbt", "vehicle", "armor", "armour", "truck", "kamyon", "ifv"];

diag_log format ["[TC2][VIRT] CAS ucus id=%1 | sinif=%2 | top=%3 roket=%4 bomba=%5 fuze=%6 | arac hedefi=%7", _id, _class, _gun, _rocket, _bomb, _missile, _vehicleTarget];

[_jtacNet, format ["SANAL CAS #%1: IP'den giriş, ATTACK HEADING %2°, %3", _id, round _heading, ["piyade / genel hedef", "araç / zırh hedefi"] select _vehicleTarget]] call TC2_fnc_netInfo;

// durum makinesi (CBA PFH, 0.1 sn): [kimlik, uçak, hedef nesnesi, hedef ASL, yön, silahlar, araç hedefi mi, evre, evre başlangıcı, sayaçlar, taraf anahtarı, mesaj bayrakları]
private _args = [_id, _plane, _targetObject, [_target2D select 0, _target2D select 1, _groundZ + 1], _dirH, [_gun, _rocket, _bomb, _missile], _vehicleTarget, "APPROACH", diag_tickTime, [0, 0, 0, 0, 0], _sideKey, []];
[TC2_fnc_virtCasTick, 0.1, _args] call CBA_fnc_addPerFrameHandler;
