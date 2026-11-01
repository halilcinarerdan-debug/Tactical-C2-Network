/*
    Fonksiyon: TC2_fnc_rptLaceInfo
    Çalışma yeri: SADECE SUNUCU (saf: yalnızca okur; grup değişkeni tutar)

    Bir grubun LACE bilgisi: sistemin DOĞRULADIĞI sayılar + liderin son LACE raporu. Bilgi güvenirliği: sayılar oyundan okunur, lider
    değiştiremez; liderin renk durumları (Liquids / Ammunition) beyan niteliğindedir.
      doğrulanan: [mevcut, ilk büyüklük, yaralı-etkisiz, araç hasarı yüzde]
        ilk büyüklük = grupta görülen en yüksek üye sayısı (grup değişkeni TC2_initialSize),
        yaralı-etkisiz = ACE bilinçsiz / vanilla INCAPACITATED / hasar > 0.3 olan canlı üyeler,
        araç hasarı = grubun araçlarında en yüksek hasar (yüzde).
      son rapor: [yaş sn, [[durum, not] x4]] (45 dk içinde) ya da [].

    Parametreler:
        0: grup <GROUP>

    Dönüş: [[mevcut, ilk, yaralı, araç %], son rapor] <ARRAY>
*/

params [["_group", grpNull, [grpNull]]];

if (isNull _group) exitWith {[[0, 0, 0, 0], []]};

private _members = (units _group) select {alive _x};
private _initial = (_group getVariable ["TC2_initialSize", 0]) max (count _members);
_group setVariable ["TC2_initialSize", _initial];

private _wounded = count (_members select {
    (lifeState _x) isEqualTo "INCAPACITATED" || {_x getVariable ["ACE_isUnconscious", false]} || {(damage _x) > 0.3}
});

private _vehicles = (_members apply {vehicle _x}) select {!(_x isKindOf "CAManBase")};
private _damage = 0;
{_damage = _damage max (damage _x)} forEach _vehicles;

private _groupNet = netId _group;
private _now = diag_tickTime;
private _report = [];
{
    if ((_x select 1) isEqualTo "LACE" && {(_x select 10) isEqualTo _groupNet} && {(_now - (_x select 5)) < 2700}) then {
        _report = [round (_now - (_x select 5)), _x select 4];
    };
} forEach (missionNamespace getVariable ["TC2_reports", []]);

[[count _members, _initial, _wounded, round (_damage * 100)], _report]
