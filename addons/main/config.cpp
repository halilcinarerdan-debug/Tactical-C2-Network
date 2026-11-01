// ============================================================================
//  Tactical C2 Network (TC2) - tek PBO: tc2_main
//  Yeni asama/ozellik eklemek icin:
//    1) addons\main\<ozellik>\ klasoru ac (fn_*.sqf + CfgFunctions.hpp)
//    2) asagidaki CfgFunctions icine #include satiri ekle
//    3) XEH_preInit.sqf / XEH_postInit.sqf icine giris fonksiyonunu ekle
//  NOT: config.cpp'yi ASCII tut (Mikero rapify icin en guvenlisi).
// ============================================================================

class CfgPatches
{
    class tc2_main
    {
        name = "Tactical C2 Network";
        author = "TC2";
        url = "";
        // units[]: Zeus (curator) bu listeden addon'u aktive eder.
        units[] = {"TC2_Terminal_F"};
        weapons[] = {"TC2_CAC_Card"};
        requiredVersion = 0.1;
        // A3_Structures_F_Items_Electronics: Land_Laptop_unfolded_F bu yamada tanimli;
        // taban sinifin bizden ONCE yuklenmesi icin gerekli.
        requiredAddons[] =
        {
            "cba_main",
            "ace_main",
            "ace_common",
            "ace_interact_menu",
            "A3_Structures_F_Items_Electronics"
        };
        version = 0.1;
        versionStr = "0.1.0";
        versionAr[] = {0,1,0};
    };
};

// ----------------------------------------------------------------------------
//  Eden / Zeus kategorisi: vanilla kategorilere karismaz, kendi basligimiz altinda toplanir.
//  Eden'de: Objects (F6) > "Tactical C2 Network" > "Terminals".
// ----------------------------------------------------------------------------
class CfgEditorCategories
{
    class TC2_EdCat
    {
        displayName = "Tactical C2 Network";
    };
};

class CfgEditorSubcategories
{
    class TC2_EdSubcat_Terminals
    {
        displayName = "Terminals";
    };
};

// ----------------------------------------------------------------------------
//  1. Asama: Fiziksel terminal = vanilla acik laptop'un kendi sinifimiz.
//  Kendi sinifi olmasi: Eden/Zeus'ta bulunur, ACE eylemi YALNIZCA bu sinifa baglanir
//  (dekor laptoplar etkilenmez) ve JIP icin ekstra senkronizasyon gerekmez.
// ----------------------------------------------------------------------------
class CfgVehicles
{
    class Land_Laptop_unfolded_F;

    class TC2_Terminal_F: Land_Laptop_unfolded_F
    {
        scope = 2;
        scopeCurator = 2;
        displayName = "TC2 Command Terminal";
        author = "TC2";
        editorCategory = "TC2_EdCat";
        editorSubcategory = "TC2_EdSubcat_Terminals";
    };
};

// ----------------------------------------------------------------------------
//  Kimlik karti (CAC): terminale giris icin gereken envanter esyasi.
//  Harici bir moddaki Item_CAC_Card yoksa bu kart kullanilir. CBA_MiscItem: cba_main'in
//  genel esya taban sinifi.
// ----------------------------------------------------------------------------
class CfgWeapons
{
    class CBA_MiscItem;
    class CBA_MiscItem_ItemInfo;

    class TC2_CAC_Card: CBA_MiscItem
    {
        author = "TC2";
        scope = 2;
        displayName = "CAC Kimlik Karti";
        descriptionShort = "Common Access Card. Komuta terminallerine giris icin gerekir.";
        picture = "\a3\ui_f\data\gui\rsc\rscdisplayarsenal\itemacc_ca.paa";

        class ItemInfo: CBA_MiscItem_ItemInfo
        {
            mass = 1;
        };
    };
};

// ----------------------------------------------------------------------------
//  2. Asama: Terminal penceresi. Bos diyalog; kontroller scriptte (ctrlCreate, fn_uiOpen) kurulur.
//  enableSimulation = 1: pencere acikken oyun (MP) akmaya devam eder.
//  idd araligi 92000-92999 TC2'ye ayrilmistir.
// ----------------------------------------------------------------------------
class TC2_TerminalDialog
{
    idd = 92000;
    movingEnable = 0;
    enableSimulation = 1;
    class controlsBackground {};
    class controls {};
};

// ----------------------------------------------------------------------------
//  5. Asama: Pilot 9-Line penceresi (ACE self menusunden acilir). Bos diyalog; kontroller scriptte kurulur.
// ----------------------------------------------------------------------------
class TC2_CasDialog
{
    idd = 92100;
    movingEnable = 0;
    enableSimulation = 1;
    class controlsBackground {};
    class controls {};
};

class CfgFunctions
{
    class TC2
    {
        tag = "TC2";

        // Ortak yardimcilar (bildirim, debug)
        #include "core\CfgFunctions.hpp"

        // 1. Asama: Fiziksel terminal + OPSEC (erisim kontrolu)
        #include "terminal\CfgFunctions.hpp"

        // 2. Asama: Terminal arayuzu
        #include "ui\CfgFunctions.hpp"

        // 3. Asama: ACRE2 veri agi + basit mesajlasma
        #include "net\CfgFunctions.hpp"

        // 4. Asama: ortak harekat resmi (harita, dusman isaretleri, MicroDAGR)
        #include "cop\CfgFunctions.hpp"

        // 5. Asama: dijital 9-Line CAS
        #include "cas\CfgFunctions.hpp"
    };
};

// ----------------------------------------------------------------------------
//  remoteExec beyaz listesi. Sunucu description.ext'te CfgRemoteExec mode = 1
//  kullaniyorsa yalnizca beyaz listedeki fonksiyonlar calisir.
//    accessServerHandle : SADECE sunucuya gonderilebilir (allowedTargets = 2)
//    accessResult       : sunucu -> istemci yaniti. allowedTargets = 0 (herkes), cunku
//                         hosted MP'de host hem sunucu hem istemcidir; 1 olursa host yaniti alamaz.
//  jip = 0: bu cagrilar gecici, JIP kuyruguna eklenmez.
// ----------------------------------------------------------------------------
class CfgRemoteExec
{
    class Functions
    {
        class TC2_fnc_accessServerHandle
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_accessResult
        {
            allowedTargets = 0;
            jip = 0;
        };

        // 3. Asama (ag). *Server*: yalnizca sunucuya. Digerleri sunucu -> istemci yanitlari (hosted MP icin 0).
        class TC2_fnc_netServerReport
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_netServerSend
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_netOnStatus
        {
            allowedTargets = 0;
            jip = 0;
        };
        class TC2_fnc_netOnAck
        {
            allowedTargets = 0;
            jip = 0;
        };
        class TC2_fnc_netReceive
        {
            allowedTargets = 0;
            jip = 0;
        };

        // 4. Asama (COP). Sunucuya giden: copFieldReport, copRequest, copPlace, copRemove. Istemciye giden: copOnData, copOnAck, copDagrSync.
        class TC2_fnc_copFieldReport
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_copRequest
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_copPlace
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_copRemove
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_copOnData
        {
            allowedTargets = 0;
            jip = 0;
        };
        class TC2_fnc_copOnAck
        {
            allowedTargets = 0;
            jip = 0;
        };
        class TC2_fnc_copDagrSync
        {
            allowedTargets = 0;
            jip = 0;
        };

        // 5. Asama (CAS). Sunucuya giden: casPoll, casSend, casReadback, casAbort. Istemciye giden: casOnData, casOnAck, casOnIncoming, casOnResult.
        class TC2_fnc_casPoll
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_casSend
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_casReadback
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_casAbort
        {
            allowedTargets = 2;
            jip = 0;
        };
        class TC2_fnc_casOnData
        {
            allowedTargets = 0;
            jip = 0;
        };
        class TC2_fnc_casOnAck
        {
            allowedTargets = 0;
            jip = 0;
        };
        class TC2_fnc_casOnIncoming
        {
            allowedTargets = 0;
            jip = 0;
        };
        class TC2_fnc_casOnResult
        {
            allowedTargets = 0;
            jip = 0;
        };
    };
};

// CBA XEH: tum makinelerde (sunucu, istemci, HC) mod yuklenince calisir.
class Extended_PreInit_EventHandlers
{
    class tc2_main
    {
        init = "call compile preprocessFileLineNumbers '\z\tc2\addons\main\XEH_preInit.sqf'";
    };
};

class Extended_PostInit_EventHandlers
{
    class tc2_main
    {
        init = "call compile preprocessFileLineNumbers '\z\tc2\addons\main\XEH_postInit.sqf'";
    };
};
