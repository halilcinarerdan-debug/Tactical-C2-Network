class terminal
{
    file = "z\tc2\addons\main\terminal";

    // Kurulum
    class terminalInitSettings {};
    class terminalPostInit {};
    class terminalInitActions {};

    // Terminal objesi
    class terminalCreate {};
    class terminalGetId {};
    class terminalOpen {};

    // Erisim (OPSEC) - ortak mantik
    class accessGetCardClasses {};
    class accessHasCard {};
    class accessCheck {};
    class accessReasonText {};

    // Erisim - istemci -> sunucu -> istemci akisi
    class accessRequest {};
    class accessServerHandle {};
    class accessResult {};
};
