/*
    Fonksiyon: TC2_fnc_terminalPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf, hasInterface kontrolünden sonra)

    - Bekleyen erişim talebi değişkenini sıfırlar (-1 = bekleyen talep yok).
    - ACE eylemini terminal sınıfına bağlar.

    Parametreler: yok
    Dönüş: yok
*/

// Aynı anda tek erişim talebi: >= 0 ise o numaralı talep sunucudan yanıt bekliyor.
missionNamespace setVariable ["TC2_access_pendingId", -1];

call TC2_fnc_terminalInitActions;
