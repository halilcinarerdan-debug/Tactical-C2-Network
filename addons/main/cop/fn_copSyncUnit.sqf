/*
    Fonksiyon: TC2_fnc_copSyncUnit
    Çalışma yeri: SADECE SUNUCU

    Bir birimin MicroDAGR içeriğini eşzamanlar. Kural: yalnızca GRUP LİDERİ ve envanterinde ACE MicroDAGR
    olan birim (ACE MicroDAGR eşya sınıfı ACE_microDAGR), kendi ağındaki (görebildiği) düşman işaretlerini alır. Diğer herkes için istenen liste boştur.
    İstenen listenin özeti (str) kayıttakinden farklıysa istemciye gönderilir; böylece:
      - yeni işaret / silinen işaret / süresi dolan işaret,
      - liderlik değişimi, DAGR alma/bırakma, kanal değişimi, respawn / JIP
    hepsi AYNI mekanizmayla (olay + 10 sn'lik rapor) karşılanır. Değişiklik yoksa ağ trafiği yoktur.

    Parametreler:
        0: saha kaydı <ARRAY>  (TC2_cop_field girdisi; yerinde güncellenir)

    Dönüş: yok
*/

params [["_entry", [], [[]]]];

if (_entry isEqualTo []) exitWith {};

_entry params ["", "_unit", "", "_base", "_channel"];

private _desired = [];

if (
    (missionNamespace getVariable ["TC2_cop_dagrEnabled", true]) && {alive _unit}
    && {(leader (group _unit)) isEqualTo _unit}
    && {"ace_microdagr" in ((items _unit + assignedItems _unit) apply {toLower _x})}
) then {
    _desired = ([_base, _channel, _unit] call TC2_fnc_copMarkersFor) apply {[_x select 0, _x select 1, _x select 2]};
};

private _hash = str _desired;

if !(_hash isEqualTo (_entry select 6)) then {
    _entry set [6, _hash];
    [_unit, "TC2_fnc_copDagrSync", [_desired]] call TC2_fnc_netToUnit;
};
