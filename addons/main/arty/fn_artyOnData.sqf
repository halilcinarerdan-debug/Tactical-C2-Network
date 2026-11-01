/*
    Fonksiyon: TC2_fnc_artyOnData
    Çalışma yeri: İSTEMCİ (sunucu artyPoll'e yanıt olarak gönderir)

    TOPÇU ve FDC sekmelerinin verisini saklar ve ekranı günceller.

    Parametreler:
        0: kod <STRING>
        1: gözlemci mi <BOOL>   2: FDC mi <BOOL>
        3: alıcı FDC'ler <ARRAY>  [[netId, ad]]
        4: kendi görev özeti <ARRAY>
        5: FDC kuyruğu <ARRAY>    (görev özetleri)
        6: bataryalar <ARRAY>     [[anahtar, etiket, mürettebat, top sayısı, kullanılabilir mi]]
        7: bilinen hedef numaraları <ARRAY>  [[numara, grid]]

    Dönüş: yok
*/

if (!hasInterface) exitWith {};

params [["_code", "", [""]], ["_isObs", false, [false]], ["_isFdc", false, [false]], ["_fdcTargets", [], [[]]], ["_mine", [], [[]]], ["_queue", [], [[]]], ["_batteries", [], [[]]], ["_targets", [], [[]]]];

missionNamespace setVariable ["TC2_arty_data", [_isObs, _isFdc, _fdcTargets, _mine, _queue, _batteries, _targets]];
missionNamespace setVariable ["TC2_arty_code", _code];

call TC2_fnc_artyUiUpdate;
