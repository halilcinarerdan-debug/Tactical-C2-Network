# TC2 cerceve: TEK KAYNAK. Bu betik hem SQF kodunu (uiBuildFrame govdesi) hem de onizleme gorsellerini uretir.
# Ifadeler hem Python hem SQF'te gecerlidir (_left, _top, _w, _h, _cx, _ratio degiskenleri, + - * / ve sayilar).
import math, sys, re
from PIL import Image, ImageDraw, ImageFont

class Ops:
    def __init__(self): self.ops = []
    def rect(self, x, y, w, h, c): self.ops.append(("rect", x, y, w, h, c))
    def rr(self, x, y, w, h, r, c): self.ops.append(("rr", x, y, w, h, r, c))
    def dot(self, x, y, s, c): self.ops.append(("dot", x, y, s, c))
    def text(self, x, y, w, h, t, size, c): self.ops.append(("text", x, y, w, h, t, size, c))

def S(v):  # sayi/ifade -> metin
    return v if isinstance(v, str) else ("%.5f" % v).rstrip("0").rstrip(".")
def C(c):
    return "[%s, %s, %s, 1]" % tuple(S(v) for v in c[:3])

def tablet():
    o = Ops()
    olive, edge, black, bez = (0.235, 0.265, 0.19), (0.17, 0.19, 0.135), (0.04, 0.04, 0.045), (0.012, 0.012, 0.012)
    # govde + ust/alt kenar isigi
    o.rr("_left - 0.085", "_top - 0.05", "_w + 0.135", "_h + 0.15", 0.014, olive)
    o.rect("_left - 0.071", "_top - 0.0488", "_w + 0.107", 0.0015, (0.36, 0.4, 0.29))
    o.rect("_left - 0.071", "_top + _h + 0.097", "_w + 0.107", 0.0015, (0.11, 0.12, 0.085))
    # siyah kose koruyucular (govdeden hafif tasar)
    bh = "0.07 * _ratio"
    o.rr("_left - 0.091", "_top - 0.056", 0.07, bh, 0.02, black)
    o.rr("_left + _w - 0.014", "_top - 0.056", 0.07, bh, 0.02, black)
    o.rr("_left - 0.091", "_top + _h + 0.106 - 0.07 * _ratio", 0.07, bh, 0.02, black)
    o.rr("_left + _w - 0.014", "_top + _h + 0.106 - 0.07 * _ratio", 0.07, bh, 0.02, black)
    # ekran cercevesi (siyah cam)
    o.rr("_left - 0.016", "_top - 0.016", "_w + 0.032", "_h + 0.032", 0.008, bez)
    # vidalar
    for (x, y) in [("_left - 0.034", "_top - 0.036"), ("_left + _w + 0.024", "_top - 0.036"), ("_left - 0.034", "_top + _h + 0.082"), ("_left + _w + 0.024", "_top + _h + 0.082")]:
        o.dot(x, y, 0.008, (0.34, 0.35, 0.3))
        o.rect(x + " + 0.002", y + " + 0.0033", 0.004, 0.0012, (0.1, 0.1, 0.09))
    # sol bant: LED'ler + 3 tus
    for k, c in enumerate([(0.2, 0.8, 0.3), (0.5, 0.35, 0.07), (0.38, 0.07, 0.05)]):
        o.dot("_left - 0.058", "_top + %s" % S(0.02 + k * 0.022), 0.007, c)
    for k, t in enumerate(["PWR", "BRT", "LOCK"]):
        y = "_top + %s" % S(0.12 + k * 0.05)
        o.rect("_left - 0.07", y, 0.04, 0.028, (0.095, 0.105, 0.085))
        o.rect("_left - 0.07", y, 0.04, 0.0014, (0.22, 0.23, 0.19))
        o.text("_left - 0.07", y + " + 0.0055", 0.04, 0.02, t, 0.012, (0.6, 0.62, 0.55))
    # ust bant: kamera, yazi, havalandirma yuvalari
    o.dot("_cx - 0.003", "_top - 0.031", 0.006, (0.1, 0.12, 0.18))
    o.text("_cx - 0.1", "_top - 0.047", 0.2, 0.022, "TC2 FIELD SYSTEMS", 0.017, (0.5, 0.55, 0.42))
    for k in range(10):
        o.rect("_left + _w * 0.72 + %s" % S(k * 0.012), "_top - 0.04", 0.007, 0.0025, (0.1, 0.11, 0.08))
    # alt: entegre klavye
    o.rr("_left + 0.02", "_top + _h + 0.026", "_w - 0.04", 0.072, 0.006, (0.055, 0.06, 0.05))
    kw = "((_w - 0.096) / 15)"
    for r in range(3):
        for c in range(15):
            o.rect("_left + 0.028 + %d * %s + 0.0012" % (c, kw), "_top + _h + %s" % S(0.032 + r * 0.02), "%s - 0.0024" % kw, 0.0165, (0.15, 0.16, 0.13))
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
    return "\n".join(out)

# ---------------- Onizleme ----------------
W, H = 1.5, 0.9
PXW, PXH = 1920, 1080
sx, sy = PXW / W, PXH / H
ratio = (H / W) * (PXW / PXH)

def ev(e, env):
    return float(e) if not isinstance(e, str) else eval(e, {}, env)

def render(o, mode, out):
    img = Image.new("RGB", (PXW, PXH))
    d = ImageDraw.Draw(img)
    for yy in range(PXH):
        t = yy / PXH
        d.line([(0, yy), (PXW, yy)], fill=(int(120 - 50 * t), int(150 - 60 * t), int(190 - 110 * t)))
    w = 0.7 * W
    field = mode == "FIELD"
    h = (0.56 if field else 0.58) * H
    left = (W - w) / 2
    top = (H - (h + 0.15)) / 2 + 0.05 if field else (H - (h + 0.19)) / 2 + 0.022
    env = {"_left": left, "_top": top, "_w": w, "_h": h, "_cx": left + w / 2, "_ratio": ratio}
    col = lambda c: tuple(int(round(v * 255)) for v in c[:3])
    def rect(x, y, rw, rh, c):
        x0, y0, x1, y1 = x * sx, y * sy, (x + rw) * sx - 1, (y + rh) * sy - 1
        if x1 >= x0 and y1 >= y0: d.rectangle([x0, y0, x1, y1], fill=col(c))
    def strips(x, y, rw, rh, r, c, flip):
        rv = r * ratio
        n = min(12, max(3, round(r * sx / 4)))
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
    # ekran kose maskeleri
    cc = (0.012, 0.012, 0.012) if field else (0.01, 0.03, 0.015)
    r = 0.014; rv = r * ratio; n = 5; sh = rv / n
    for kk in range(n):
        t = (n - kk - 0.5) / n; inset = r * (1 - math.sqrt(1 - t * t))
        for (px, py, pw) in [(left, top + kk * sh, inset), (left + w - inset, top + kk * sh, inset), (left, top + h - (kk + 1) * sh, inset), (left + w - inset, top + h - (kk + 1) * sh, inset)]:
            rect(px, py, pw, sh + 0.0012, cc)
    img.save(out)

if __name__ == "__main__":
    t, dsk = tablet(), desk()
    render(t, "FIELD", "tablet_cercevesi_onizleme.png")
    render(dsk, "DESK", "pc_cercevesi_onizleme.png")
    open("frame_field.sqf.txt", "w").write(sqf(t))
    open("frame_desk.sqf.txt", "w").write(sqf(dsk))
    print("tablet ops", len(t.ops), "desk ops", len(dsk.ops))
