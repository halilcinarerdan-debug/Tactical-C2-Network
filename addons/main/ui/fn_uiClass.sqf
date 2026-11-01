/*
    Fonksiyon: TC2_fnc_uiClass
    Çalışma yeri: İstemci (saf fonksiyon)

    Kontrol sınıfı adını yazı tipi ayarına göre seçer. CBA "TC2_ui_mono" açıksa (varsayılan) yapılı metin ve menü düğmesi için
    EtelkaMonospacePro'lu sınıflar (config.cpp: TC2_RscStructuredTextMono, TC2_RscButtonMenuMono) kullanılır; diğer sınıflar aynen kalır
    (onların yazı tipi uiFontApply ile ctrlSetFont komutuyla verilir).

    Parametreler:
        0: sınıf adı <STRING>

    Dönüş: <STRING>
*/

params [["_class", "", [""]]];

if !(missionNamespace getVariable ["TC2_ui_mono", true]) exitWith {_class};

switch (_class) do {
    case "RscStructuredText": {"TC2_RscStructuredTextMono"};
    case "RscButtonMenu": {"TC2_RscButtonMenuMono"};
    default {_class};
}
