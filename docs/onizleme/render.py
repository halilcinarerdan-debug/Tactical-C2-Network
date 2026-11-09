# TC2 cerceve onizlemesi: uiBuildFrame / uiBuildFrameCorners / uiOpen geometrisinin birebir Python portu (yaklasik; oyun ekran goruntusu degildir)
import math, sys
from PIL import Image, ImageDraw, ImageFont

W, H = 1.5, 0.9            # varsayilan 16:9 safeZone yaklasigi (GUI birimi)
PXW, PXH = 1920, 1080
sx, sy = PXW / W, PXH / H
ratio = (H / W) * (PXW / PXH)

def col(c):
    return tuple(int(round(v * 255)) for v in c[:3])

class Canvas:
    def __init__(self, bg):
        self.img = Image.new("RGB", (PXW, PXH), bg)
        self.d = ImageDraw.Draw(self.img)
        self.font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", 15)
        self.fontb = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf", 15)
        self.small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", 11)
    def rect(self, x, y, w, h, c):
        x0, y0, x1, y1 = x * sx, y * sy, (x + w) * sx - 1, (y + h) * sy - 1
        if x1 < x0 or y1 < y0:
            return
        self.d.rectangle([x0, y0, x1, y1], fill=col(c))
    def dot(self, x, y, size, c):
        self.d.ellipse([x * sx, y * sy, (x + size) * sx, (y + size * ratio) * sy], fill=col(c))
    def text(self, x, y, t, c, font=None):
        self.d.text((x * sx, y * sy), t, fill=col(c), font=font or self.font)

def strips(cv, x, y, rw, rh, r, c, flip):
    rv = r * ratio
    STEPS = min(12, max(3, round(r * sx / 4)))
    sh = rv / STEPS
    for k in range(STEPS):
        t = (STEPS - k - 0.5) / STEPS
        inset = r * (1 - math.sqrt(1 - t * t))
        py = y + rh - (k + 1) * sh if flip else y + k * sh
        cv.rect(x + inset, py, rw - 2 * inset, sh + 0.0012, c)
def rround(cv, x, y, rw, rh, r, c):
    rv = r * ratio
    cv.rect(x, y + rv - 0.0006, rw, rh - 2 * rv + 0.0012, c)
    strips(cv, x, y, rw, rh, r, c, False)
    strips(cv, x, y, rw, rh, r, c, True)

def frame(cv, mode, left, top, w, h):
    cx = left + w / 2
    if mode == "DESK":
        side, chin = 0.018, 0.045
        bodyTop, bodyH, bodyBottom = top - side, h + side + chin, top + h + chin
        cv.rect(cx - 0.032, bodyBottom - 0.004, 0.064, 0.034, (0.15, 0.15, 0.16))
        cv.rect(cx - 0.012, bodyBottom + 0.004, 0.024, 0.026, (0.1, 0.1, 0.11))
        rround(cv, cx - 0.13, bodyBottom + 0.028, 0.26, 0.016, 0.008, (0.11, 0.11, 0.12))
        kbTop, kbW = bodyBottom + 0.052, 0.42
        kbLeft = cx - kbW / 2
        rround(cv, kbLeft, kbTop, kbW, 0.054, 0.008, (0.09, 0.09, 0.1))
        keyW = (kbW - 0.016) / 14
        for row in range(3):
            for c in range(14):
                cv.rect(kbLeft + 0.008 + c * keyW + 0.0012, kbTop + 0.006 + row * 0.0125, keyW - 0.0024, 0.0105, (0.2, 0.2, 0.22))
        cv.rect(kbLeft + 0.06, kbTop + 0.0435, kbW - 0.12, 0.0085, (0.2, 0.2, 0.22))
        rround(cv, kbLeft + kbW + 0.022, kbTop + 0.006, 0.026, 0.044, 0.011, (0.1, 0.1, 0.11))
        cv.rect(kbLeft + kbW + 0.0345, kbTop + 0.006, 0.0012, 0.017, (0.03, 0.03, 0.03))
        rround(cv, left - side, bodyTop, w + 2 * side, bodyH, 0.016, (0.075, 0.075, 0.085))
        cv.rect(left - side + 0.016, bodyTop + 0.001, w + 2 * side - 0.032, 0.0014, (0.22, 0.22, 0.25))
        cv.rect(left - 0.006, top - 0.006, w + 0.012, h + 0.012, (0.01, 0.03, 0.015))
        cv.text(cx - 0.012, top + h + 0.014, "TC2", (0.4, 0.4, 0.44))
        rround(cv, left + w - 0.052, top + h + 0.017, 0.03, 0.014, 0.005, (0.16, 0.16, 0.18))
        cv.dot(left + w - 0.094, top + h + 0.0205, 0.009, (0.2, 0.9, 0.3))
        cv.dot(cx - 0.005, top - 0.0125, 0.01, (0.2, 0.2, 0.24))
    else:
        side, vert = 0.058, 0.042
        case, dark = (0.16, 0.19, 0.13), (0.09, 0.11, 0.07)
        bw = 0.082; bh = bw * ratio
        cv.rect(left + w * 0.58, top - vert - 0.0075, 0.05, 0.0105, (0.06, 0.07, 0.05))
        cv.rect(left + w * 0.58 + 0.062, top - vert - 0.006, 0.026, 0.009, (0.06, 0.07, 0.05))
        cv.rect(left + w * 0.58 + 0.098, top - vert - 0.006, 0.04, 0.009, (0.06, 0.07, 0.05))
        rround(cv, left - side, top - vert, w + 2 * side, h + 2 * vert, 0.036, case)
        rround(cv, left - side, top - vert, bw, bh, 0.036, dark)
        rround(cv, left + w + side - bw, top - vert, bw, bh, 0.036, dark)
        rround(cv, left - side, top + h + vert - bh, bw, bh, 0.036, dark)
        rround(cv, left + w + side - bw, top + h + vert - bh, bw, bh, 0.036, dark)
        rround(cv, left - 0.03, top - 0.024, w + 0.06, h + 0.048, 0.02, (0.12, 0.145, 0.095))
        rround(cv, left - 0.018, top - 0.0155, w + 0.036, h + 0.031, 0.012, (0.02, 0.02, 0.02))
        cv.rect(left - side + 0.036, top - vert + 0.0015, w + 2 * side - 0.072, 0.0015, (0.3, 0.35, 0.25))
        cv.dot(left - 0.0335, top + h * 0.5 - 0.007, 0.014, (0.04, 0.04, 0.05))
        cv.dot(left - 0.0335 + 0.003, top + h * 0.5 - 0.007 + 0.003 * ratio, 0.008, (0.12, 0.14, 0.2))
        cv.dot(left - 0.0305, top + h * 0.5 - 0.036, 0.006, (0.1, 0.1, 0.1))
        cv.dot(left + w + 0.0225, top + h * 0.5 - 0.012, 0.007, (0.08, 0.08, 0.08))
        cv.dot(left + w + 0.0225, top + h * 0.5 + 0.012, 0.007, (0.08, 0.08, 0.08))
        for k in range(4):
            cv.dot(left + w * 0.5 - 0.027 + k * 0.018, top + h + 0.0235, 0.0065, (0.8, 0.65, 0.25))
        cv.text(left + 0.02, top + h + 0.02, "TC2 TACTICAL", (0.42, 0.5, 0.36), cv.small)

def screen(cv, left, top, w, h, title):
    green = (0.25, 1, 0.35)
    cv.rect(left, top, w, h, (0, 0.04, 0))
    cv.rect(left, top, w - 0.14, 0.05, (0, 0.2, 0.05))
    cv.text(left + 0.01, top + 0.012, title, green, cv.fontb)
    cv.text(left + (w - 0.14) * 0.55, top + 0.014, "NW 300°  05:05  024 057  YUK 12 m", (0.7, 1, 0.75))
    cv.rect(left + w - 0.14, top, 0.14, 0.05, (0.45, 0.05, 0.05))
    cv.text(left + w - 0.1, top + 0.014, "KAPAT", (1, 1, 1))
    tabs = ["ANA", "HARITA", "CAS", "TOPCU", "FDC", "OPORD", "RAPOR", "MEDEVAC", "LOJISTIK", "UAV"]
    tw = w / len(tabs)
    for i, t in enumerate(tabs):
        cv.rect(left + i * tw + 0.001, top + 0.05, tw - 0.002, 0.05, (0.1, 0.45, 0.15) if i == 1 else (0.02, 0.1, 0.03))
        cv.text(left + i * tw + 0.008, top + 0.064, t, green)
    # harita alani + arac cubugu (taslak)
    cy = top + 0.115
    names = ["ISARET KOY", "ISARET SIL", "BIRIM / LACE", "OLC", "MERKEZ", "KATMAN: ACIK"]
    bw = (w - 0.03 - 5 * 0.008) / 6
    for i, n in enumerate(names):
        cv.rect(left + 0.015 + i * (bw + 0.008), cy, bw, 0.04, (0.02, 0.1, 0.03))
        cv.text(left + 0.02 + i * (bw + 0.008), cy + 0.01, n, green, cv.small)
    cv.rect(left + 0.015, cy + 0.048, w - 0.03, h - 0.115 - 0.048 - 0.05, (0.45, 0.58, 0.38))
    mx, my = left + 0.015, cy + 0.048
    mw, mh = w - 0.03, h - 0.115 - 0.048 - 0.05
    cv.dot(mx + mw * 0.45, my + mh * 0.5, 0.012, (0.1, 0.4, 1))
    cv.dot(mx + mw * 0.62, my + mh * 0.3, 0.012, (1, 0.1, 0.1))
    cv.text(mx + mw * 0.45 + 0.016, my + mh * 0.5 - 0.004, "Alpha 1-1 [GREEN]", (0.0, 0.2, 0.6), cv.small)
    cv.rect(mx + 0.004, my + mh - 0.044, mw * 0.62, 0.04, (0, 0.05, 0.02))
    cv.text(mx + 0.01, my + mh - 0.034, "  0245 0571   YUK 12 m   842 m   047° / 0835 mil", (0.7, 1, 0.75), cv.small)
    cv.rect(left, top + h - 0.04, w, 0.04, (0, 0.12, 0.03))
    cv.text(left + 0.01, top + h - 0.03, "ESC = kapat", (0.12, 0.6, 0.2))

def corners(cv, mode, left, top, w, h):
    c = (0.01, 0.03, 0.015) if mode == "DESK" else (0.03, 0.03, 0.03)
    r = 0.014; rv = r * ratio; n = 5; sh = rv / n
    for k in range(n):
        t = (n - k - 0.5) / n
        inset = r * (1 - math.sqrt(1 - t * t))
        for (px, py, pw) in [(left, top + k * sh, inset), (left + w - inset, top + k * sh, inset),
                             (left, top + h - (k + 1) * sh, inset), (left + w - inset, top + h - (k + 1) * sh, inset)]:
            cv.rect(px, py, pw, sh + 0.0012, c)

def build(mode, out):
    cv = Canvas((60, 78, 52))   # arka plan: oyun sahnesi yerine duz zemin
    # basit gokyuzu/zemin gradyani
    for yy in range(PXH):
        t = yy / PXH
        cv.d.line([(0, yy), (PXW, yy)], fill=(int(120 - 50 * t), int(150 - 60 * t), int(190 - 110 * t)))
    w = 0.7 * W
    field = mode == "FIELD"
    h = (0.64 if field else 0.58) * H
    left = (W - w) / 2
    top = (H - h) / 2 if field else (H - (h + 0.18)) / 2 + 0.018
    frame(cv, mode, left, top, w, h)
    screen(cv, left, top, w, h, "  TC2 SAHA   |   Alpha 1-1   |   hcinar33" if field else "  TC2 TERMINAL   |   TOC-ANA   |   hcinar33")
    corners(cv, mode, left, top, w, h)
    cv.img.save(out)

build("FIELD", "tablet_cercevesi_onizleme.png")
build("DESK", "pc_cercevesi_onizleme.png")
print("ok")
