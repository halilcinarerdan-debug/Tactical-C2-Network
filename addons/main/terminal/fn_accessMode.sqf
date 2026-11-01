/*
    Fonksiyon: TC2_fnc_accessMode
    Çalışma yeri: Her makine (saf fonksiyon)

    Cihaz kullanım modu:
      DESK   masa başı terminal (seviye karttan/kadrodan; yazma izni seviyeye göre)
      FIELD  saha tableti, kullanıcı lider (grup lideri / JTAC / gözlemci / FDC / rütbe eşiği): TAM kullanım (rapor, işaret, mesaj, formlar)
      VIEW   saha tableti, kullanıcı lider DEĞİL (er/nefer): YALNIZCA İZLEME — harita ve işaretler (ve Level 1 görev metni); yazamaz.
    Amaç bilgi güvenirliğidir: yetkisiz birliklerin raporlarla harita resmini kirletmesi önlenir. VIEW kuralı sunucuda zorlanır.

    Parametreler:
        0: asker <OBJECT>
        1: terminal / saha cihazı <OBJECT>

    Dönüş: "DESK" | "FIELD" | "VIEW" <STRING>
*/

params [["_unit", objNull, [objNull]], ["_terminal", objNull, [objNull]]];

if !(_terminal isEqualTo _unit) exitWith {"DESK"};
if (([_unit] call TC2_fnc_userLevel) >= 2) exitWith {"FIELD"};

"VIEW"
