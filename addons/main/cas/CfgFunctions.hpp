class cas
{
    file = "z\tc2\addons\main\cas";

    // Kurulum
    class casInitSettings {};
    class casPostInit {};

    // Saf (dogruluk kaynagi: doktrin)
    class casValidate {};
    class casGrid {};
    class casLines {};
    class casCompare {};

    // Sunucu
    class casTargets {};
    class casReqIndex {};
    class casPoll {};
    class casSend {};
    class casApplyReadback {};
    class casReadback {};
    class casAbort {};

    // Zeus / Eden modulu: JTAC ata-kaldir
    class hasRole {};
    class isJtac {};
    class moduleRole {};
    class roleSet {};
    class roleOnResult {};

    // Istemci - ortak
    class casOnData {};
    class casOnAck {};
    class casOnIncoming {};
    class casOnResult {};
    class casResultText {};

    // Istemci - JTAC formu (CAS sekmesi)
    class casUiBuild {};
    class casUiUpdate {};
    class casUiGather {};
    class casUiSend {};
    class casUiAbort {};
    class casUiRequest {};
    class casUiChanged {};

    // Istemci - pilot (ACE self menu)
    class casPilotOpen {};
    class casPilotUpdate {};
    class casPilotReadback {};

    // Test
    class debugCasPilot {};
};
