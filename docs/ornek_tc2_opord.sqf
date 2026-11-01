/*
    ORNEK: Mission klasorune "tc2_opord.sqf" adiyla koyun (mission.sqm ile ayni klasor). Sunucu mission basinda okur ve yayimlar.
    Format: [baslik, DTG, gizlilik etiketi, [[anahtar, baslik, seviye (1-3), metin], ...], yayimlayan (istege bagli)]
    Seviye: 1 herkes, 2 lider/rol/rutbe, 3 komuta. Metindeki satir sonu icin "\n" YERINE toString [10] kullanin ya da asagidaki gibi birlestirin.
    Anahtarlar (TASKORG, 1A, ... FIRES) docs/DOKTRIN_NOTLARI_OPORD.md'deki sablonla ayni olmak zorunda DEGILDIR; istediginiz bolumleri tanimlayin.
*/

private _nl = toString [10];

[
    "OPERASYON EMRI 01",
    "011800Z",
    "TC2 EGITIM - DAGITIM SINIRLI",
    [
        ["2", "2. GOREV (Mission)", 1,
            "1. Takim, 011900Z'de KOY 'KIRMIZI'yi kusatir ve duser; amac, alcak seviyede gecit yolunu acik tutmaktir."],
        ["3A", "3.a KOMUTAN NIYETI (Commander's Intent)", 1,
            "AMAC: Gecit yolunu ana kuvvet icin acik tutmak." + _nl + "SON DURUM: KOY dost kontrolunde, yol trafige acik." + _nl + "RISK: Sivil varligi; ROE'ye uyulur."],
        ["1B", "1.b DUSMAN KUVVETLERI (Enemy Forces)", 2,
            "KOY'de yaklasik 12 kisilik piyade, 1 PKM, 1 RPG. En olasi hareket tarzi: savunma. En tehlikeli: kuzeyden karsi atak."],
        ["3D", "3.d ATES KONSEPTI (Concept of Fires)", 2,
            "GOREV: Dusman PKM'sini bastir. AMAC: Atilis hattinin gecisi. YONTEM: 81mm havan (BAT-1) bastirma, ardindan CAS (JTAC Alpha). ETKI: Bastirma/yoketme."],
        ["CCIR", "3.g.1 KRITIK BILGI IHTIYACLARI (CCIR)", 3,
            "PIR: Dusmanin karsi atak elemani var mi? FFIR: Kayip veya yaralanma 3'u asarsa."],
        ["5C", "5.c HABERLESME (Signal)", 3,
            "Ana ag: Kanal 1. CAS lazer kodu: 1688. Parola: KARTAL."]
    ],
    "Takim Komutani"
]
