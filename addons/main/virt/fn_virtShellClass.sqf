/*
    Fonksiyon: TC2_fnc_virtShellClass
    Çalışma yeri: SADECE SUNUCU (saf)

    Sanal batarya için mühimmat türüne (HE | SMOKE | WP | ILLUM) ve CBA kalibresine göre mermi (CfgAmmo) sınıfı seçer. Adaylar sırayla denenir; ilk MEVCUT sınıf
    döner (sınıf adları oyun / mod sürümüne göre değişebilir). Hiçbiri yoksa "" döner.

    Parametreler:
        0: mühimmat türü <STRING>

    Dönüş: <STRING> mermi sınıfı ("" = yok)
*/

params [["_projectile", "HE", [""]]];

private _caliber = missionNamespace getVariable ["TC2_virt_artyCaliber", "155"];

private _candidates = switch (_projectile) do {
    case "SMOKE": {
        switch (_caliber) do {
            case "82":  {["Smoke_82mm_AMOS_White", "Smoke_120mm_AMOS_White"]};
            case "120": {["Smoke_120mm_AMOS_White", "Smoke_82mm_AMOS_White"]};
            default {["Smoke_155mm_AMOS_White", "Smoke_120mm_AMOS_White", "Smoke_82mm_AMOS_White"]};
        }
    };
    case "WP": {["Smoke_120mm_AMOS_White", "Smoke_82mm_AMOS_White", "Smoke_155mm_AMOS_White"]};
    case "ILLUM": {
        switch (_caliber) do {
            case "155": {["Flare_155mm_AMOS_White", "Flare_120mm_AMOS_White", "Flare_82mm_AMOS_White"]};
            default {["Flare_82mm_AMOS_White", "Flare_120mm_AMOS_White", "Flare_155mm_AMOS_White"]};
        }
    };
    default {
        switch (_caliber) do {
            case "82":  {["Sh_82mm_AMOS", "Sh_120mm_HE"]};
            case "120": {["Sh_120mm_HE", "Sh_82mm_AMOS"]};
            default {["Sh_155mm_AMOS", "Sh_120mm_HE", "Sh_82mm_AMOS"]};
        }
    };
};

private _result = "";
{
    if (isClass (configFile >> "CfgAmmo" >> _x)) exitWith {_result = _x};
} forEach _candidates;

_result
