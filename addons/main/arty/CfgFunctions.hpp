class arty
{
    file = "z\tc2\addons\main\arty";

    // Kurulum
    class artyInitSettings {};

    // Saf (dogruluk kaynagi: ATP 3-09.30)
    class artyValidate {};
    class artyLines {};
    class artyCorrect {};
    class artyMilsToDeg {};

    // Sunucu - yardimcilar
    class artyResolvePos {};
    class artyIsGun {};
    class artyBatteries {};
    class artyAmmo {};
    class artyNearestFriendly {};
    class artyMissionIndex {};
    class artyEvent {};
    class artyFdcTargets {};

    // Sunucu - islemler
    class artyPoll {};
    class artySendCff {};
    class artyFdcAction {};
    class artyObsAction {};
    class artyExecute {};
    class artyGunFired {};
    class artyComplete {};

    // Istemci
    class artyOnData {};
    class artyOnEvent {};
    class artyOnAck {};
    class artyOnGunOrder {};
    class artyUiRequest {};
    class artyUiUpdate {};
    class artyUiChanged {};
    class artyUiGather {};
    class artyUiSend {};
    class artyUiObsAction {};
    class artyUiFdcAction {};
    class artyObsBuild {};
    class artyFdcBuild {};
};
