/*
    Fonksiyon: TC2_fnc_notify
    Çalışma yeri: İstemci

    Ekranda ACE tarzı yapılandırılmış bir bildirim gösterir. Hata / başarı / bilgi rengi ayrıdır.
    TC2_debug ayarı açıksa aynı metin systemChat'e de düşer.

    Parametreler:
        0: metin <STRING>  ('<' ve '&' içermemeli: structured text olarak işlenir)
        1: tür <STRING>    "info" (varsayılan) | "success" | "error"
        2: boyut <NUMBER>  yazı boyutu (varsayılan 1.0; ACE varsayılanı 1.5 ekrana büyük geliyordu)

    Dönüş: yok
*/

params [["_text", "", [""]], ["_type", "info", [""]], ["_size", 1, [0]]];

private _color = switch (toLower _type) do {
    case "error":   {"#ff5555"};
    case "success": {"#55ff77"};
    default         {"#d0d0d0"};
};

[parseText format ["<t color='%1'>%2</t>", _color, _text], _size] call ace_common_fnc_displayTextStructured;

if (missionNamespace getVariable ["TC2_debug", false]) then {
    systemChat format ["[TC2] %1", _text];
};
