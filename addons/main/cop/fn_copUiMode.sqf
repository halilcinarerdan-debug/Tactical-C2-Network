/*
    Fonksiyon: TC2_fnc_copUiMode
    Çalışma yeri: İstemci (düğme olayı / copOnAck)

    Harita tıklama modunu ayarlar ve düğmeleri vurgular. Aynı moda tekrar basmak modu kapatır.

    Parametreler:
        0: mod <STRING>  "PLACE" | "DELETE" | "INFO" | "MEASURE" | boş = mevcut modu yalnızca yeniden boya (varsayılan)

    Dönüş: yok
*/

params [["_request", "", [""]]];

private _mode = missionNamespace getVariable ["TC2_cop_mode", ""];

if !(_request isEqualTo "") then {
    _mode = if (_mode isEqualTo _request) then {""} else {_request};
    if !(_mode isEqualTo "MEASURE") then {missionNamespace setVariable ["TC2_cop_measure", []]};
    missionNamespace setVariable ["TC2_cop_mode", _mode];

    switch (_mode) do {
        case "PLACE":  {[format ["  Haritaya tıklayın: %1 konacak.", [missionNamespace getVariable ["TC2_cop_placeType", "INF"]] call TC2_fnc_copTypeName], [1, 0.5, 0.5, 1]] call TC2_fnc_copUiStatus};
        case "DELETE": {["  Silmek istediğiniz işarete tıklayın.", [1, 0.8, 0.2, 1]] call TC2_fnc_copUiStatus};
        case "INFO":   {["  Bir dost birime tıklayın: LACE bilgisi.", [0.25, 1, 0.35, 1]] call TC2_fnc_copUiStatus};
        case "MEASURE": {
            missionNamespace setVariable ["TC2_cop_measure", []];
            ["  ÖLÇ: iki noktaya sırayla tıklayın (A, sonra B).", [0.25, 1, 0.35, 1]] call TC2_fnc_copUiStatus;
        };
        default        {call TC2_fnc_copUiRequest};
    };
};

private _display = findDisplay 92000;
if (isNull _display) exitWith {};

(_display displayCtrl 92041) ctrlSetBackgroundColor ([[0.02, 0.1, 0.03, 1], [0.5, 0.1, 0.1, 1]] select (_mode isEqualTo "PLACE"));
(_display displayCtrl 92042) ctrlSetBackgroundColor ([[0.02, 0.1, 0.03, 1], [0.45, 0.35, 0.05, 1]] select (_mode isEqualTo "DELETE"));
(_display displayCtrl 92045) ctrlSetBackgroundColor ([[0.02, 0.1, 0.03, 1], [0.1, 0.45, 0.15, 1]] select (_mode isEqualTo "MEASURE"));
(_display displayCtrl 92044) ctrlSetBackgroundColor ([[0.02, 0.1, 0.03, 1], [0.1, 0.45, 0.15, 1]] select (_mode isEqualTo "INFO"));

// LACE paneli yalnızca INFO modunda görünür.
if !(_mode isEqualTo "INFO") then {
    (_display displayCtrl 92046) ctrlShow false;
};
