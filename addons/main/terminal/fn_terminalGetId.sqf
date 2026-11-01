/*
    Fonksiyon: TC2_fnc_terminalGetId
    Çalışma yeri: Her makine

    Terminalin okunabilir kimliğini verir. Öncelik sırası:
      1) TC2_terminalId objesi değişkeni (terminalCreate ile verilir; Eden init'inde de
         `this setVariable ["TC2_terminalId", "TOC-ANA", true]` yazılabilir)
      2) Eden "Variable Name" alanı
      3) netId (her zaman vardır)

    Parametreler:
        0: terminal <OBJECT>

    Dönüş: kimlik <STRING>
*/

params [["_terminal", objNull, [objNull]]];

if (isNull _terminal) exitWith {"?"};

private _id = _terminal getVariable ["TC2_terminalId", ""];
if (_id isEqualTo "") then {_id = vehicleVarName _terminal};
if (_id isEqualTo "") then {_id = netId _terminal};

_id
