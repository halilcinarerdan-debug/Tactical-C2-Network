# TC2 cerceve: TEK KAYNAK. Bu betik hem SQF kodunu (uiBuildFrame govdesi) hem de onizleme gorsellerini uretir.
# Ifadeler hem Python hem SQF'te gecerlidir (_left, _top, _w, _h, _cx, _ratio degiskenleri, + - * / ve sayilar).
import math, sys, re, os
from PIL import Image, ImageDraw, ImageFont

class Ops:
    def __init__(self): self.ops = []
    def rect(self, x, y, w, h, c): self.ops.append(("rect", x, y, w, h, c))
    def rr(self, x, y, w, h, r, c): self.ops.append(("rr", x, y, w, h, r, c))
    def dot(self, x, y, s, c): self.ops.append(("dot", x, y, s, c))
    def text(self, x, y, w, h, t, size, c): self.ops.append(("text", x, y, w, h, t, size, c))
    def pic(self, path, x, y, w, h): self.ops.append(("pic", path, x, y, w, h))

def S(v):  # sayi/ifade -> metin
    return v if isinstance(v, str) else ("%.5f" % v).rstrip("0").rstrip(".")
def C(c):
    return "[%s, %s, %s, %s]" % (S(c[0]), S(c[1]), S(c[2]), S(c[3]) if len(c) > 3 else "1")

import random

def dust(o, rnd, region, n):
    """region = (xmin_expr_base, xrange_expr, ymin, yrange) : ifadeler; rastgele parcacik uretir"""
    pass

def tablet():
    """Samsung Galaxy Tab Active5 Tactical Edition'i andiran sagam tablet; Thales telsizi tarzi MAT, TANELI (stipple) kaucuk doku:
    kabartma (isik ust-sol, golge alt-sag), vidali yukselmis ekran kenari, tozlu benekler, cizikler, asinma."""
    o = Ops()
    rnd = random.Random(20261109)
    case, dark, lip, black = (0.14, 0.165, 0.115), (0.075, 0.09, 0.06), (0.105, 0.128, 0.085), (0.015, 0.015, 0.015)
    HL, SH = (0.5, 0.56, 0.45), (0.02, 0.03, 0.015)   # kabartma isigi / golgesi (alpha ile kullanilir)
    # ust tuslar (kilifin arkasindan tasar): Active tusu, guc, ses  (+ kabartma)
    for (dx, wd, yy, hh) in [(0.0, 0.05, -0.0495, 0.0105), (0.062, 0.026, -0.048, 0.009), (0.098, 0.04, -0.048, 0.009)]:
        o.rect("_left + _w * 0.58 + %s" % S(dx), "_top %s" % S(yy).replace("-", "- "), wd, hh, (0.045, 0.055, 0.035))
        o.rect("_left + _w * 0.58 + %s" % S(dx), "_top %s" % S(yy).replace("-", "- "), wd, 0.0012, HL + (0.3,))
    # kilif + kose koruyucular + yukselmis ic kenar + ekran cercevesi
    o.rr("_left - 0.058", "_top - 0.042", "_w + 0.116", "_h + 0.084", 0.036, case)
    for (x, y) in [("_left - 0.058", "_top - 0.042"), ("_left + _w + 0.058 - 0.082", "_top - 0.042"),
                   ("_left - 0.058", "_top + _h + 0.042 - 0.082 * _ratio"), ("_left + _w + 0.058 - 0.082", "_top + _h + 0.042 - 0.082 * _ratio")]:
        o.rr(x, y, 0.082, "0.082 * _ratio", 0.036, dark)
    o.rr("_left - 0.03", "_top - 0.024", "_w + 0.06", "_h + 0.048", 0.02, lip)
    # yukselmis ic kenar kabartmasi: ust/sol acik, alt/sag koyu
    o.rect("_left - 0.012", "_top - 0.0238", "_w + 0.024", 0.0016, HL + (0.3,))
    o.rect("_left - 0.0298", "_top - 0.012", 0.0015, "_h + 0.024", HL + (0.22,))
    o.rect("_left - 0.012", "_top + _h + 0.0222", "_w + 0.024", 0.0016, SH + (0.6,))
    o.rect("_left + _w + 0.0283", "_top - 0.012", 0.0015, "_h + 0.024", SH + (0.6,))
    o.rr("_left - 0.018", "_top - 0.0155", "_w + 0.036", "_h + 0.031", 0.012, black)
    # ekran girintisi (ici golge ust/sol, isik alt/sag)
    o.rect("_left - 0.0165", "_top - 0.0153", "_w + 0.033", 0.0014, (0, 0, 0, 0.9))
    o.rect("_left - 0.0165", "_top + _h + 0.0132", "_w + 0.033", 0.0012, HL + (0.2,))
    # kilif ust / alt kenar isigi ve golgesi
    o.rect("_left - 0.022", "_top - 0.0405", "_w + 0.044", 0.0016, HL + (0.32,))
    o.rect("_left - 0.022", "_top + _h + 0.0391", "_w + 0.044", 0.0016, SH + (0.9,))
    # kose koruyucu kabartmasi (ust-sol kenarlar acik)
    for (x, y) in [("_left - 0.052", "_top - 0.0395"), ("_left + _w + 0.0105", "_top - 0.0395")]:
        o.rect(x, y, 0.03, 0.0013, HL + (0.2,))
    # tutma yuvasi (ust bantta nervur / havalandirma, telsiz gibi)
    for k in range(5):
        y = "_top - 0.0385 + %s" % S(k * 0.0042)
        o.rect("_left + _w * 0.1", y, "_w * 0.28", 0.0017, (0.01, 0.015, 0.008, 0.6))
        o.rect("_left + _w * 0.1", y + " + 0.0017", "_w * 0.28", 0.0009, HL + (0.16,))
    # ekran kenari vidalari: sol ve sag kenarda 3'er (parlak ust-sol, koyu alt-sag)
    for xx in ["_left - 0.0245", "_left + _w + 0.0165"]:
        for k in range(3):
            y = "_top + _h * %s" % S(0.18 + k * 0.32)
            o.dot(xx, y, 0.0078, (0.03, 0.035, 0.025))
            o.dot(xx + " + 0.0006", y + " + 0.0005", 0.0066, (0.34, 0.37, 0.3))
            o.rect(xx + " + 0.0018", y + " + 0.0034", 0.0042, 0.0011, (0.06, 0.06, 0.05))
    # ----- TOZ / TANELI DOKU (tohumlu rastgele) -----
    bands = [
        ("_left - 0.056", 0.038, "_top - 0.032", "_h + 0.064"),          # sol
        ("_left + _w + 0.018", 0.038, "_top - 0.032", "_h + 0.064"),     # sag
        ("_left - 0.03", "_w + 0.06", "_top - 0.04", 0.022),             # ust
        ("_left - 0.03", "_w + 0.06", "_top + _h + 0.0155", 0.024),      # alt
    ]
    def pos(b):
        bx, bw, by, bh = b
        fx, fy = rnd.random(), rnd.random()
        px = "%s + %s * %s" % (bx, S(fx), bw if isinstance(bw, str) and False else ("(%s)" % bw if isinstance(bw, str) else S(bw)))
        py = "%s + %s * %s" % (by, S(fy), ("(%s)" % bh if isinstance(bh, str) else S(bh)))
        return px, py
    # genis, cok hafif toz filmi + alt kisimda koyulasma (kir)
    for b in bands:
        o.rect(b[0], b[2], b[1], b[3], (0.68, 0.6, 0.45, 0.05))
    o.rect("_left - 0.056", "_top + _h * 0.5", 0.038, "_h * 0.5 + 0.032", (0.03, 0.03, 0.02, 0.2))
    o.rect("_left + _w + 0.018", "_top + _h * 0.45", 0.038, "_h * 0.55 + 0.032", (0.03, 0.03, 0.02, 0.2))
    o.rect("_left - 0.03", "_top + _h + 0.0155", "_w + 0.06", 0.024, (0.03, 0.03, 0.02, 0.15))
    # bulutlanma (mottling): orta boy, cok dusuk alfa, acik/koyu
    for i in range(36):
        px, py = pos(rnd.choice(bands))
        w_, h_ = rnd.choice([0.008, 0.012, 0.018, 0.026]), rnd.choice([0.006, 0.01, 0.014])
        c = rnd.choice([(0.02, 0.025, 0.015, 0.1), (0.02, 0.025, 0.015, 0.14), (0.5, 0.55, 0.42, 0.06), (0.62, 0.55, 0.42, 0.06)])
        o.rect(px, py, w_, h_, c)
    # ince benekler (stipple): koyu ve acik
    for i in range(150):
        px, py = pos(rnd.choice(bands))
        w_ = rnd.choice([0.0010, 0.0014, 0.0018, 0.0024])
        h_ = rnd.choice([0.0010, 0.0014, 0.0018])
        if rnd.random() < 0.5:
            c = (0.0, 0.01, 0.0, rnd.choice([0.16, 0.24, 0.32]))
        else:
            c = rnd.choice([(0.66, 0.6, 0.47, rnd.choice([0.07, 0.12, 0.18])), (0.45, 0.5, 0.38, rnd.choice([0.07, 0.12]))])
        o.rect(px, py, w_, h_, c)
    # cizikler / asinma izleri (acik, ince)
    for i in range(14):
        px, py = pos(rnd.choice(bands))
        if rnd.random() < 0.55:
            w_, h_ = rnd.choice([0.012, 0.02, 0.03, 0.045]), 0.0009
        else:
            w_, h_ = 0.0009, rnd.choice([0.01, 0.016, 0.026])
        o.rect(px, py, w_, h_, (0.74, 0.76, 0.68, rnd.choice([0.1, 0.16, 0.24])))
    # kilif kenari boya cikmasi
    for i in range(18):
        side = rnd.choice(["t", "b", "l", "r"])
        f = rnd.random()
        ln = rnd.choice([0.008, 0.016, 0.028])
        if side == "t": o.rect("_left - 0.02 + %s * (_w + 0.04)" % S(f), "_top - 0.0412", ln, 0.0013, (0.46, 0.5, 0.39, 0.32))
        if side == "b": o.rect("_left - 0.02 + %s * (_w + 0.04)" % S(f), "_top + _h + 0.0399", ln, 0.0013, (0.46, 0.5, 0.39, 0.28))
        if side == "l": o.rect("_left - 0.0572", "_top + %s * _h" % S(f), 0.0013, ln, (0.46, 0.5, 0.39, 0.28))
        if side == "r": o.rect("_left + _w + 0.0559", "_top + %s * _h" % S(f), 0.0013, ln, (0.46, 0.5, 0.39, 0.28))
    # ----- sensorler, pogo, yazi (kabartma yazi: koyu golge + acik ust) -----
    o.dot("_left - 0.0335", "_top + _h * 0.5 - 0.007", 0.014, (0.03, 0.03, 0.035))
    o.dot("_left - 0.0305", "_top + _h * 0.5 - 0.004", 0.008, (0.1, 0.12, 0.18))
    o.dot("_left - 0.0305", "_top + _h * 0.5 - 0.036", 0.006, (0.08, 0.08, 0.08))
    o.dot("_left + _w + 0.0225", "_top + _h * 0.5 - 0.012", 0.007, (0.06, 0.06, 0.06))
    o.dot("_left + _w + 0.0225", "_top + _h * 0.5 + 0.012", 0.007, (0.06, 0.06, 0.06))
    for k in range(4):
        o.dot("_left + _w * 0.5 - 0.027 + %s" % S(k * 0.018), "_top + _h + 0.0225", 0.0065, (0.55, 0.45, 0.18))
    o.text("_left + 0.0405", "_top + _h + 0.0195", 0.12, 0.022, "TC2 TACTICAL", 0.016, (0.02, 0.03, 0.015))
    o.text("_left + 0.04", "_top + _h + 0.0188", 0.12, 0.022, "TC2 TACTICAL", 0.016, (0.42, 0.48, 0.36))
    return o

TEXDIR = "\\z\\tc2\\addons\\main\\data\\"
def tablet_tex():
    """GERCEK DOKULU saha cihazi: 8 parcali (4 kose + 4 kenar) .paa kasa; kucuk ayrintilar (tuslar, vidalar, sensorler, pogo, yazi) kontrol olarak ustte."""
    o = Ops()
    # ust tuslar (kasanin arkasindan tasar)
    for (dx, wd, yy, hh) in [(0.0, 0.05, -0.0495, 0.0105), (0.062, 0.026, -0.048, 0.009), (0.098, 0.04, -0.048, 0.009)]:
        o.rect("_left + _w * 0.58 + %s" % S(dx), "_top %s" % S(yy).replace("-", "- "), wd, hh, (0.045, 0.055, 0.035))
        o.rect("_left + _w * 0.58 + %s" % S(dx), "_top %s" % S(yy).replace("-", "- "), wd, 0.0012, (0.5, 0.56, 0.45, 0.3))
    # ARKA ZEMİN: parçalar arasındaki piksel dikişlerinde ve ekran kenarında oyun arka planı (beyaz/parlak) görünmesin
    o.rect("_left - 0.04", "_top - 0.03", "_w + 0.08", "_h + 0.06", (0.02, 0.02, 0.02))
    cs, csv = "0.082", "0.082 * _ratio"
    x0, y0 = "_left - 0.058", "_top - 0.042"
    o.pic(TEXDIR + "tab_tl_ca.paa", x0, y0, cs, csv)
    o.pic(TEXDIR + "tab_tr_ca.paa", "_left + _w + 0.058 - 0.082", y0, cs, csv)
    o.pic(TEXDIR + "tab_bl_ca.paa", x0, "_top + _h + 0.042 - 0.082 * _ratio", cs, csv)
    o.pic(TEXDIR + "tab_br_ca.paa", "_left + _w + 0.058 - 0.082", "_top + _h + 0.042 - 0.082 * _ratio", cs, csv)
    o.pic(TEXDIR + "tab_top_ca.paa", "_left - 0.058 + 0.0805", y0, "_w + 0.116 - 0.161", 0.046)
    o.pic(TEXDIR + "tab_bottom_ca.paa", "_left - 0.058 + 0.0805", "_top + _h - 0.004", "_w + 0.116 - 0.161", 0.046)
    o.pic(TEXDIR + "tab_left_ca.paa", x0, "_top - 0.042 + 0.0805 * _ratio", 0.062, "_h + 0.084 - 0.161 * _ratio")
    o.pic(TEXDIR + "tab_right_ca.paa", "_left + _w - 0.004", "_top - 0.042 + 0.0805 * _ratio", 0.062, "_h + 0.084 - 0.161 * _ratio")
    # tutma nervurleri (ust bant)
    for k in range(5):
        y = "_top - 0.0385 + %s" % S(k * 0.0042)
        o.rect("_left + _w * 0.1", y, "_w * 0.28", 0.0017, (0.01, 0.015, 0.008, 0.6))
        o.rect("_left + _w * 0.1", y + " + 0.0017", "_w * 0.28", 0.0009, (0.5, 0.56, 0.45, 0.16))
    # ekran kenari vidalari
    for xx in ["_left - 0.0245", "_left + _w + 0.0165"]:
        for k in range(3):
            y = "_top + _h * %s" % S(0.18 + k * 0.32)
            o.dot(xx, y, 0.0078, (0.03, 0.035, 0.025))
            o.dot(xx + " + 0.0006", y + " + 0.0005", 0.0066, (0.34, 0.37, 0.3))
            o.rect(xx + " + 0.0018", y + " + 0.0034", 0.0042, 0.0011, (0.06, 0.06, 0.05))
    o.dot("_left - 0.0335", "_top + _h * 0.5 - 0.007", 0.014, (0.03, 0.03, 0.035))
    o.dot("_left - 0.0305", "_top + _h * 0.5 - 0.004", 0.008, (0.1, 0.12, 0.18))
    o.dot("_left - 0.0305", "_top + _h * 0.5 - 0.036", 0.006, (0.08, 0.08, 0.08))
    o.dot("_left + _w + 0.0225", "_top + _h * 0.5 - 0.012", 0.007, (0.06, 0.06, 0.06))
    o.dot("_left + _w + 0.0225", "_top + _h * 0.5 + 0.012", 0.007, (0.06, 0.06, 0.06))
    for k in range(4):
        o.dot("_left + _w * 0.5 - 0.027 + %s" % S(k * 0.018), "_top + _h + 0.0225", 0.0065, (0.55, 0.45, 0.18))
    o.text("_left + 0.0405", "_top + _h + 0.0195", 0.12, 0.022, "TC2 TACTICAL", 0.016, (0.02, 0.03, 0.015))
    o.text("_left + 0.04", "_top + _h + 0.0188", 0.12, 0.022, "TC2 TACTICAL", 0.016, (0.42, 0.48, 0.36))
    return o

def desk_tex():
    """GERCEK DOKULU masa basi bilgisayar: monitor (4 kenar), ayak, klavye, fare .paa; cene tuslari, LED, yazi, vidalar kontrol olarak ustte."""
    o = Ops()
    D = TEXDIR
    o.pic(D + "desk_stand_ca.paa", "_cx - 0.13", "_top + _h + 0.054", 0.26, 0.044)
    o.pic(D + "desk_keyboard_ca.paa", "_cx - 0.21", "_top + _h + 0.11", 0.42, 0.054)
    o.pic(D + "desk_mouse_ca.paa", "_cx + 0.232", "_top + _h + 0.116", 0.026, 0.044)
    # arka zemin (dikis / ekran kenari beyazligini onler)
    o.rect("_left - 0.012", "_top - 0.012", "_w + 0.024", "_h + 0.024", (0.012, 0.025, 0.015))
    o.rect("_left - 0.02", "_top + _h - 0.002", "_w + 0.04", 0.058, (0.06, 0.06, 0.068))
    o.pic(D + "desk_top_ca.paa", "_left - 0.022", "_top - 0.022", "_w + 0.044", 0.026)
    o.pic(D + "desk_bottom_ca.paa", "_left - 0.022", "_top + _h - 0.004", "_w + 0.044", 0.062)
    o.pic(D + "desk_left_ca.paa", "_left - 0.022", "_top - 0.0015", 0.026, "_h + 0.003")
    o.pic(D + "desk_right_ca.paa", "_left + _w - 0.004", "_top - 0.0015", 0.026, "_h + 0.003")
    o.dot("_cx - 0.005", "_top - 0.0165", 0.01, (0.18, 0.18, 0.22))
    o.text("_left + 0.01", "_top + _h + 0.0185", 0.1, 0.026, "TC2", 0.02, (0.45, 0.45, 0.5))
    for k, t in enumerate(["MENU", "SRC", "-", "+", "AUTO", "PWR"]):
        x = "_left + _w - %s" % S(0.29 - k * 0.044)
        o.rect(x, "_top + _h + 0.022", 0.034, 0.016, (0.14, 0.14, 0.155))
        o.rect(x, "_top + _h + 0.022", 0.034, 0.0012, (0.28, 0.28, 0.3, 0.7))
        o.text(x, "_top + _h + 0.0235", 0.034, 0.014, t, 0.011, (0.62, 0.62, 0.66))
    o.dot("_left + _w - 0.02", "_top + _h + 0.0265", 0.008, (0.2, 0.85, 0.3))
    for (x, y) in [("_left - 0.0155", "_top - 0.0155"), ("_left + _w + 0.0085", "_top - 0.0155"), ("_left - 0.0155", "_top + _h + 0.0455"), ("_left + _w + 0.0085", "_top + _h + 0.0455")]:
        o.dot(x, y, 0.007, (0.2, 0.2, 0.22))
    return o

def desk():
    o = Ops()
    body = (0.085, 0.085, 0.09)
    # ayak (arkada)
    o.rect("_cx - 0.032", "_top + _h + 0.054", 0.064, 0.034, (0.14, 0.14, 0.15))
    o.rect("_cx - 0.012", "_top + _h + 0.062", 0.024, 0.026, (0.09, 0.09, 0.1))
    o.rr("_cx - 0.13", "_top + _h + 0.082", 0.26, 0.016, 0.008, (0.11, 0.11, 0.12))
    # klavye + fare
    o.rr("_cx - 0.21", "_top + _h + 0.11", 0.42, 0.054, 0.008, (0.07, 0.07, 0.08))
    kw = 0.404 / 14
    for r in range(3):
        for c in range(14):
            o.rect("_cx - 0.202 + %s" % S(c * kw + 0.0012), "_top + _h + %s" % S(0.116 + r * 0.0125), S(kw - 0.0024), 0.0105, (0.16, 0.16, 0.18))
    o.rect("_cx - 0.15", "_top + _h + 0.1535", 0.3, 0.0085, (0.16, 0.16, 0.18))
    o.rr("_cx + 0.232", "_top + _h + 0.116", 0.026, 0.044, 0.011, (0.1, 0.1, 0.11))
    o.rect("_cx + 0.2445", "_top + _h + 0.116", 0.0012, 0.017, (0.03, 0.03, 0.03))
    # monitor govdesi + isik / golge + ekran girintisi
    o.rr("_left - 0.022", "_top - 0.022", "_w + 0.044", "_h + 0.08", 0.01, body)
    o.rect("_left - 0.012", "_top - 0.0208", "_w + 0.024", 0.0014, (0.25, 0.25, 0.28))
    o.rect("_left - 0.012", "_top + _h + 0.0555", "_w + 0.024", 0.0014, (0.04, 0.04, 0.045))
    o.rect("_left - 0.006", "_top - 0.006", "_w + 0.012", "_h + 0.012", (0.01, 0.03, 0.015))
    o.dot("_cx - 0.005", "_top - 0.0165", 0.01, (0.18, 0.18, 0.22))
    # cene: yazi, 6 tus, LED
    o.text("_left + 0.01", "_top + _h + 0.0185", 0.1, 0.026, "TC2", 0.02, (0.45, 0.45, 0.5))
    for k, t in enumerate(["MENU", "SRC", "-", "+", "AUTO", "PWR"]):
        x = "_left + _w - %s" % S(0.29 - k * 0.044)
        o.rect(x, "_top + _h + 0.022", 0.034, 0.016, (0.14, 0.14, 0.155))
        o.rect(x, "_top + _h + 0.022", 0.034, 0.0012, (0.28, 0.28, 0.3))
        o.text(x, "_top + _h + 0.0235", 0.034, 0.014, t, 0.011, (0.62, 0.62, 0.66))
    o.dot("_left + _w - 0.02", "_top + _h + 0.0265", 0.008, (0.2, 0.85, 0.3))
    # kose vidalari
    for (x, y) in [("_left - 0.0155", "_top - 0.0155"), ("_left + _w + 0.0085", "_top - 0.0155"), ("_left - 0.0155", "_top + _h + 0.0455"), ("_left + _w + 0.0085", "_top + _h + 0.0455")]:
        o.dot(x, y, 0.007, (0.2, 0.2, 0.22))
    return o

# ---------------- SQF uretimi ----------------
def sqf(o):
    out = []
    for op in o.ops:
        k = op[0]
        if k == "rect":
            _, x, y, w, h, c = op
            out.append("    [%s, %s, %s, %s, %s] call _rect;" % (S(x), S(y), S(w), S(h), C(c)))
        elif k == "rr":
            _, x, y, w, h, r, c = op
            out.append("    [%s, %s, %s, %s, %s, %s] call _round;" % (S(x), S(y), S(w), S(h), S(r), C(c)))
        elif k == "dot":
            _, x, y, s, c = op
            out.append("    [%s, %s, %s, %s] call _dot;" % (S(x), S(y), S(s), C(c)))
        elif k == "text":
            _, x, y, w, h, t, size, c = op
            out.append('    [%s, %s, %s, %s, "%s", %s, %s] call _label;' % (S(x), S(y), S(w), S(h), t, S(size), C(c)))
        elif k == "pic":
            _, path, x, y, w, h = op
            out.append('    ["%s", %s, %s, %s, %s] call _pic;' % (path, S(x), S(y), S(w), S(h)))
    return "\n".join(out)

# ---------------- Onizleme ----------------
TEXPNG = os.environ.get('TC2_TEXPNG', 'tex_png')
W, H = 1.5, 0.9
PXW, PXH = 1920, 1080
sx, sy = PXW / W, PXH / H
ratio = (H / W) * (PXW / PXH)

def ev(e, env):
    return float(e) if not isinstance(e, str) else eval(e, {}, env)

def render(o, mode, out, mask_prefix=None):
    img = Image.new("RGB", (PXW, PXH))
    d = ImageDraw.Draw(img, "RGBA")
    for yy in range(PXH):
        t = yy / PXH
        d.line([(0, yy), (PXW, yy)], fill=(int(120 - 50 * t), int(150 - 60 * t), int(190 - 110 * t)))
    w = 0.7 * W
    field = mode == "FIELD"
    h = (0.64 if field else 0.58) * H
    left = (W - w) / 2
    top = (H - h) / 2 if field else (H - (h + 0.19)) / 2 + 0.022
    env = {"_left": left, "_top": top, "_w": w, "_h": h, "_cx": left + w / 2, "_ratio": ratio}
    col = lambda c: tuple(int(round(v * 255)) for v in c[:3]) + ((int(round(c[3] * 255)),) if len(c) > 3 else ())
    def rect(x, y, rw, rh, c):
        x0, y0, x1, y1 = x * sx, y * sy, (x + rw) * sx - 1, (y + rh) * sy - 1
        if x1 >= x0 and y1 >= y0: d.rectangle([x0, y0, x1, y1], fill=col(c))
    def strips(x, y, rw, rh, r, c, flip):
        rv = r * ratio
        n = min(8, max(3, round(r * sx / 4)))
        sh = rv / n
        for k in range(n):
            t = (n - k - 0.5) / n
            inset = r * (1 - math.sqrt(1 - t * t))
            py = y + rh - (k + 1) * sh if flip else y + k * sh
            rect(x + inset, py, rw - 2 * inset, sh + 0.0012, c)
    f_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", 12)
    f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", 15)
    fb = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", 15)
    for op in o.ops:
        k = op[0]
        if k == "rect":
            rect(ev(op[1], env), ev(op[2], env), ev(op[3], env), ev(op[4], env), op[5])
        elif k == "rr":
            x, y, rw, rh, r = [ev(v, env) for v in op[1:6]]
            c = op[6]; rv = r * ratio
            rect(x, y + rv - 0.0006, rw, rh - 2 * rv + 0.0012, c)
            strips(x, y, rw, rh, r, c, False); strips(x, y, rw, rh, r, c, True)
        elif k == "dot":
            x, y, s = [ev(v, env) for v in op[1:4]]
            d.ellipse([x * sx, y * sy, (x + s) * sx, (y + s * ratio) * sy], fill=col(op[4]))
        elif k == "pic":
            name = op[1].split("\\")[-1].replace(".paa", ".png")
            x, y, pw_, ph_ = [ev(v, env) for v in op[2:6]]
            im = Image.open(os.path.join(TEXPNG, name)).convert("RGBA").resize((max(1, int(round(pw_ * sx))), max(1, int(round(ph_ * sy)))), Image.LANCZOS)
            img.paste(im, (int(round(x * sx)), int(round(y * sy))), im)
        elif k == "text":
            x, y = ev(op[1], env), ev(op[2], env)
            ww = ev(op[3], env)
            size = op[6]
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", max(8, int(size * sy * 0.62)))
            tw = d.textlength(op[5], font=font)
            d.text((x * sx + max(0, (ww * sx - tw) / 2) if ww < 0.05 else x * sx, y * sy), op[5], fill=col(op[7]), font=font)
    # ekran icerigi (taslak)
    green = (0.25, 1, 0.35)
    rect(left, top, w, h, (0, 0.04, 0))
    rect(left, top, w - 0.14, 0.05, (0, 0.2, 0.05))
    d.text((left * sx + 12, (top + 0.012) * sy), "  TC2 SAHA   |   Alpha 1-1   |   hcinar33" if field else "  TC2 TERMINAL   |   TOC-ANA   |   hcinar33", fill=col(green), font=fb)
    d.text(((left + (w - 0.14) * 0.55) * sx, (top + 0.014) * sy), "NW 300°  05:05  024 057  YUK 12 m", fill=col((0.7, 1, 0.75)), font=f)
    rect(left + w - 0.14, top, 0.14, 0.05, (0.45, 0.05, 0.05))
    d.text(((left + w - 0.1) * sx, (top + 0.014) * sy), "KAPAT", fill=(255, 255, 255), font=f)
    tabs = ["ANA", "HARITA", "CAS", "TOPCU", "FDC", "OPORD", "RAPOR", "MEDEVAC", "LOJISTIK", "UAV"]
    tw_ = w / len(tabs)
    for i, t in enumerate(tabs):
        rect(left + i * tw_ + 0.001, top + 0.05, tw_ - 0.002, 0.05, (0.1, 0.45, 0.15) if i == 1 else (0.02, 0.1, 0.03))
        d.text(((left + i * tw_ + 0.008) * sx, (top + 0.064) * sy), t, fill=col(green), font=f)
    cy = top + 0.115
    names = ["ISARET KOY", "ISARET SIL", "BIRIM / LACE", "OLC", "MERKEZ", "KATMAN: ACIK"]
    bw = (w - 0.03 - 5 * 0.008) / 6
    for i, n in enumerate(names):
        rect(left + 0.015 + i * (bw + 0.008), cy, bw, 0.04, (0.02, 0.1, 0.03))
        d.text(((left + 0.02 + i * (bw + 0.008)) * sx, (cy + 0.01) * sy), n, fill=col(green), font=f_small)
    mx, my, mw, mh = left + 0.015, cy + 0.048, w - 0.03, h - 0.115 - 0.048 - 0.05
    rect(mx, my, mw, mh, (0.45, 0.58, 0.38))
    d.ellipse([(mx + mw * 0.45) * sx, (my + mh * 0.5) * sy, (mx + mw * 0.45 + 0.012) * sx, (my + mh * 0.5 + 0.012 * ratio) * sy], fill=(26, 102, 255))
    d.ellipse([(mx + mw * 0.62) * sx, (my + mh * 0.3) * sy, (mx + mw * 0.62 + 0.012) * sx, (my + mh * 0.3 + 0.012 * ratio) * sy], fill=(255, 26, 26))
    rect(mx + 0.004, my + mh - 0.044, mw * 0.62, 0.04, (0, 0.05, 0.02))
    d.text(((mx + 0.01) * sx, (my + mh - 0.034) * sy), "  0245 0571   YUK 12 m   842 m   047° / 0835 mil", fill=col((0.7, 1, 0.75)), font=f_small)
    rect(left, top + h - 0.04, w, 0.04, (0, 0.12, 0.03))
    d.text(((left + 0.01) * sx, (top + h - 0.03) * sy), "ESC = kapat", fill=col((0.12, 0.6, 0.2)), font=f)
    # ekran kose maskeleri: dokulu modda gercek kenar yumusatmali .png maskeler, yedekte seritler
    r = 0.014; rv = r * ratio
    if mask_prefix:
        for kk, (px, py) in {"tl": (left, top), "tr": (left + w - r, top), "bl": (left, top + h - rv), "br": (left + w - r, top + h - rv)}.items():
            im = Image.open(os.path.join(TEXPNG, "%s_scr_%s_ca.png" % (mask_prefix, kk))).convert("RGBA").resize((max(1, int(round(r * sx))), max(1, int(round(rv * sy)))), Image.LANCZOS)
            img.paste(im, (int(round(px * sx)), int(round(py * sy))), im)
    else:
        cc = (0.015, 0.015, 0.015) if field else (0.01, 0.03, 0.015)
        n = 5; sh = rv / n
        for kk in range(n):
            t = (n - kk - 0.5) / n; inset = r * (1 - math.sqrt(1 - t * t))
            for (px, py, pw) in [(left, top + kk * sh, inset), (left + w - inset, top + kk * sh, inset), (left, top + h - (kk + 1) * sh, inset), (left + w - inset, top + h - (kk + 1) * sh, inset)]:
                rect(px, py, pw, sh + 0.0012, cc)
    img.save(out)

if __name__ == "__main__":
    t, dsk = tablet(), desk()
    tt = tablet_tex()
    dt = desk_tex()
    render(tt, "FIELD", "tablet_cercevesi_onizleme.png", "tab")
    render(t, "FIELD", "tablet_cercevesi_prosedurel_onizleme.png")
    render(dt, "DESK", "pc_cercevesi_onizleme.png", "desk")
    render(dsk, "DESK", "pc_cercevesi_prosedurel_onizleme.png")
    open("frame_field.sqf.txt", "w").write(sqf(t))
    open("frame_field_tex.sqf.txt", "w").write(sqf(tt))
    open("frame_desk.sqf.txt", "w").write(sqf(dsk))
    open("frame_desk_tex.sqf.txt", "w").write(sqf(dt))
    print("tablet ops", len(t.ops), "tablet_tex ops", len(tt.ops), "desk ops", len(dsk.ops))
