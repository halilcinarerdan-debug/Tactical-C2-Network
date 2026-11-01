/*
    Fonksiyon: TC2_fnc_artyValidate
    Çalışma yeri: Her makine (saf fonksiyon). Sunucu KARAR için, istemci anında geri bildirim için çağırır.

    Call for fire (CFF) formunu ATP 3-09.30 bölüm 4'e göre denetler. Form verisi 15 elemanlı sabit dizidir:

         0 görev türü: ADJUST | FFE | SUPPRESS | IMM_SUPP | IMM_SMOKE
         1 konum yöntemi: GRID | POLAR | SHIFT
         2 GRID için konum ASL [x,y,z]                (aksi []) 
         3 POLAR: [yön mil, mesafe m, dikey kayma m]  (aksi [])
         4 SHIFT: [bilinen nokta anahtarı, yön mil, sol-sağ m (+sağ), add-drop m (+add), up-down m (+up)]  (aksi [])
         5 hedef tanımı (ne, ne yapıyor, kaç, ...)    6 koruma: OPEN | DUGIN | BUNKER
         7 düzeltme türü: AREA | PRECISION            8 DANGER CLOSE (bool)     9 MARK (bool)
        10 yörünge: LOW | HIGH                       11 mühimmat: HE | SMOKE | WP | ILLUM
        12 hacim: top başına mermi (FFE)             13 kontrol: FWR | AMC | CANNOT_OBSERVE      14 süre sn (bastırma/duman; 0 = yok)

    Doktrin kuralları: IMMEDIATE SUPPRESSION / SMOKE tek aktarımdır -> kontrol yalnızca FWR (AMC yok); SUPPRESS süre ile verilir;
    POLAR ve SHIFT yönü 0-6399 mil; hedef tanımı zorunlu (FDC mühimmatı buna göre seçer); hacim FFE'de top başına 1-10;
    DANGER CLOSE gerekliliği (dostlar 600 m içinde) konum bilindikten sonra SUNUCUDA ayrıca denetlenir.

    Parametreler:
        0: form verisi <ARRAY>

    Dönüş: [geçerli mi <BOOL>, hatalar <ARRAY of STRING>]
*/

params [["_data", [], [[]]]];

private _shape = ["", "", [], [], [], "", "", "", false, false, "", "", 0, "", 0];

if (count _data != count _shape) exitWith {[false, ["Geçersiz form."]]};

private _typesOk = true;
{
    if !((_data select _forEachIndex) isEqualType _x) exitWith {_typesOk = false};
} forEach _shape;
if (!_typesOk) exitWith {[false, ["Geçersiz form verisi."]]};

_data params [
    "_type", "_method", "_grid", "_polar", "_shift", "_description", "_protection", "_adjustType",
    "_dangerClose", "_mark", "_trajectory", "_projectile", "_volume", "_control", "_duration"
];

private _errors = [];
private _isNumber = {_this isEqualType 0};

if !(_type in ["ADJUST", "FFE", "SUPPRESS", "IMM_SUPP", "IMM_SMOKE"]) then {_errors pushBack "Görev türü geçersiz."};
if !(_method in ["GRID", "POLAR", "SHIFT"]) then {_errors pushBack "Konum yöntemi geçersiz."};

switch (_method) do {
    case "GRID": {
        if !(count _grid == 3 && {(_grid select 0) call _isNumber} && {(_grid select 1) call _isNumber} && {(_grid select 2) call _isNumber}) then {_errors pushBack "Hedef konumu seçilmedi (GRID: HARİTA sekmesinden işaret koyun)."};
    };
    case "POLAR": {
        if !(count _polar == 3 && {(_polar select 0) call _isNumber} && {(_polar select 1) call _isNumber} && {(_polar select 2) call _isNumber}) then {
            _errors pushBack "POLAR: yön, mesafe ve dikey kayma gerekli.";
        } else {
            if ((_polar select 0) < 0 || {(_polar select 0) > 6399}) then {_errors pushBack "POLAR: yön 0-6399 mil olmalı."};
            if ((_polar select 1) <= 0 || {(_polar select 1) > 20000}) then {_errors pushBack "POLAR: mesafe 1-20000 m olmalı."};
            if (abs (_polar select 2) > 500) then {_errors pushBack "POLAR: dikey kayma en çok 500 m."};
        };
    };
    case "SHIFT": {
        if !(count _shift == 5 && {(_shift select 0) isEqualType ""} && {!((_shift select 0) isEqualTo "")} && {(_shift select 1) call _isNumber} && {(_shift select 2) call _isNumber} && {(_shift select 3) call _isNumber} && {(_shift select 4) call _isNumber}) then {
            _errors pushBack "SHIFT: bilinen nokta, yön, sol/sağ, add/drop ve up/down gerekli.";
        } else {
            if ((_shift select 1) < 0 || {(_shift select 1) > 6399}) then {_errors pushBack "SHIFT: yön 0-6399 mil olmalı."};
            if (abs (_shift select 2) > 5000 || {abs (_shift select 3) > 5000}) then {_errors pushBack "SHIFT: sol/sağ ve add/drop en çok 5000 m."};
            if (abs (_shift select 4) > 500) then {_errors pushBack "SHIFT: up/down en çok 500 m."};
        };
    };
};

if (_description isEqualTo "" || {count _description > 60}) then {_errors pushBack "Hedef tanımı gerekli (en çok 60 karakter): ne, ne yapıyor, kaç, koruma."};
if !(_protection in ["OPEN", "DUGIN", "BUNKER"]) then {_errors pushBack "Koruma derecesi geçersiz."};
if !(_adjustType in ["AREA", "PRECISION"]) then {_errors pushBack "Düzeltme türü geçersiz."};
if !(_trajectory in ["LOW", "HIGH"]) then {_errors pushBack "Yörünge geçersiz."};
if !(_projectile in ["HE", "SMOKE", "WP", "ILLUM"]) then {_errors pushBack "Mühimmat geçersiz."};
if (_volume < 1 || {_volume > 10} || {_volume != floor _volume}) then {_errors pushBack "Hacim top başına 1-10 mermi olmalı."};
if !(_control in ["FWR", "AMC", "CANNOT_OBSERVE"]) then {_errors pushBack "Kontrol yöntemi geçersiz."};
if (_duration < 0 || {_duration > 600}) then {_errors pushBack "Süre 0-600 sn olmalı."};

// Acil görevler tek aktarımdır: AT MY COMMAND yok.
if (_type in ["IMM_SUPP", "IMM_SMOKE"] && {_control isEqualTo "AMC"}) then {_errors pushBack "IMMEDIATE görevlerde AT MY COMMAND kullanılmaz."};
if (_type isEqualTo "SUPPRESS" && {_duration <= 0}) then {_errors pushBack "SUPPRESS için süre (DURATION) verilmeli."};
if (_type isEqualTo "IMM_SMOKE" && {!(_projectile isEqualTo "SMOKE")}) then {_errors pushBack "IMMEDIATE SMOKE için mühimmat SMOKE olmalı."};

[_errors isEqualTo [], _errors]
