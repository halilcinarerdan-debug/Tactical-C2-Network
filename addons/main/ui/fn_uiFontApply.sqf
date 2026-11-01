/*
    Fonksiyon: TC2_fnc_uiFontApply
    Çalışma yeri: İstemci (uiOpen ve casPilotOpen, pencere tamamen kurulduktan sonra)

    CBA "TC2_ui_mono" açıksa penceredeki metin kontrollerine (sabit metin, yazı kutusu, açılır liste, liste) EtelkaMonospacePro yazı tipini verir.
    Yapılı metin ve menü düğmesi bunun yerine sınıf düzeyinde (uiClass) ayarlanır. Tek seferlik; kare başına iş yok.
    EtelkaMonospacePro oyunun kendi yazı tipidir (CfgFontFamilies); yazı tipi eşit genişliklidir (karakterler hizalı, rakamlar ve harfler ayırt edilir).

    Parametreler:
        0: pencere <DISPLAY>

    Dönüş: yok
*/

params [["_display", displayNull, [displayNull]]];

if (isNull _display || {!(missionNamespace getVariable ["TC2_ui_mono", true])}) exitWith {};

{
    if ((ctrlType _x) in [0, 2, 4, 5]) then {
        _x ctrlSetFont "EtelkaMonospacePro";
    };
} forEach (allControls _display);
