/*
    Fonksiyon: TC2_fnc_copPostInit
    Çalışma yeri: İstemci (XEH_postInit.sqf, hasInterface kontrolünden sonra)

    Telsizi olan her oyuncu durumunu sunucuya 10 sn'de bir bildirir ("saha varlığı"). Sunucu bu kayıtla
    haritadaki dostları ve MicroDAGR eşzamanlamasını yönetir. Terminal açık olması GEREKMEZ.
    Telsiz yoksa hiçbir şey gönderilmez. Tek, hafif, 10 sn gecikmeli CBA PFH.

    Parametreler: yok
    Dönüş: yok
*/

missionNamespace setVariable ["TC2_cop_mode", ""];
missionNamespace setVariable ["TC2_cop_data", [[], []]];

// İlk bildirim açılıştan kısa süre sonra, sonra 10 sn'de bir.
[{call TC2_fnc_copHeartbeat}, [], 5] call CBA_fnc_waitAndExecute;
[{call TC2_fnc_copHeartbeat}, 10] call CBA_fnc_addPerFrameHandler;
