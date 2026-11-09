# TC2 masa basi bilgisayar dokulari: monitor (4 kenar), ayak, klavye, fare. Mat antrasit plastik (ince tane, kabartma).
import math, os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

OUT = sys.argv[1] if len(sys.argv) > 1 else "tex_png"
os.makedirs(OUT, exist_ok=True)
SS = 1.6
sx, sy = 1280 * SS, 1200 * SS
ratio = (0.9 / 1.5) * (1920 / 1080)

def blur(a, s):
    a = np.asarray(a, np.float32)
    pad = int(3 * s) + 2
    p = np.pad(a, pad, mode="edge")
    fy = np.fft.fftfreq(p.shape[0]).astype(np.float32).reshape(-1, 1)
    fx = np.fft.rfftfreq(p.shape[1]).astype(np.float32).reshape(1, -1)
    k = np.exp(-2 * (math.pi ** 2) * (s ** 2) * (fy ** 2 + fx ** 2)).astype(np.float32)
    out = np.fft.irfft2(np.fft.rfft2(p) * k, s=p.shape)
    return out[pad:-pad, pad:-pad].astype(np.float32)

def col(c): return np.array(c, np.float32).reshape(1, 1, 3)

class Scene:
    def __init__(self, PW, PH, seed):
        self.PW, self.PH = PW, PH
        self.rng = np.random.default_rng(seed)
    def rr(self, x, y, w, h, r, ss=2):
        m = Image.new("L", (self.PW * ss, self.PH * ss), 0)
        ImageDraw.Draw(m).rounded_rectangle([x * ss, y * ss, (x + w) * ss - 1, (y + h) * ss - 1], radius=max(0.5, r) * ss, fill=255)
        return np.asarray(m.resize((self.PW, self.PH), Image.LANCZOS), np.float32) / 255.0
    def noise(self, s):
        n = blur(self.rng.standard_normal((self.PH, self.PW)).astype(np.float32), s)
        return n / (n.std() + 1e-6)

def finish(sc, albedo, hmap, alpha, grain_amp, light=(0.5, 0.7), base=0.74, gain=0.5, dust=0.01, extra=None):
    gy, gx = np.gradient(hmap)
    shade = np.clip(base + (-gx * light[0] - gy * light[1]) * gain, 0.3, 1.5)
    img = albedo * shade[..., None]
    up = np.clip(-gy * 0.9, 0, 1)
    img += (up * 0.5)[..., None] * col((0.5, 0.5, 0.55)) * 0.10
    img += dust * col((0.55, 0.52, 0.45))
    ao = np.clip(blur(hmap, 4) - hmap, 0, None)
    img *= (1 - np.clip(ao * 0.03, 0, 0.12))[..., None]
    if extra is not None: img = extra(img)
    img = np.clip(img, 0, 1)
    return Image.fromarray((np.dstack([img, alpha]) * 255 + 0.5).astype(np.uint8), "RGBA")

def save(im, name, size):
    im.resize(size, Image.LANCZOS).save(os.path.join(OUT, name))

# ================= MONITOR =================
w, h = 0.7 * 1.5, 0.58 * 0.9
X0, Y0 = -0.022, -0.022
W0, H0 = w + 0.044, h + 0.08
PW, PH = int(round(W0 * sx)), int(round(H0 * sy))
sc = Scene(PW, PH, 20261110)
ux = lambda v: (v - X0) * sx
uy = lambda v: (v - Y0) * sy
body = sc.rr(0, 0, PW, PH, 0.01 * sx)
recess = sc.rr(ux(-0.006), uy(-0.006), (w + 0.012) * sx, (h + 0.012) * sy, 0.003 * sx)
MG = 0.004
mx_, my_ = int(round(MG * sx)), int(round(MG * sy))
screen = np.zeros((PH, PW), np.float32); screen[int(uy(0)) + my_:int(uy(h)) - my_, int(ux(0)) + mx_:int(ux(w)) - mx_] = 1
grain = sc.noise(0.8) * 0.6 + sc.noise(1.7) * 0.35
hmap = grain * 0.10 + blur(body, 2.2) * 5.0 - blur(recess, 1.6) * 4.0
alb = col((0.125, 0.125, 0.135)) * np.ones((PH, PW, 1), np.float32)
alb = alb * (1 - recess[..., None]) + col((0.01, 0.03, 0.015)) * recess[..., None]
alb = alb * (1 + 0.02 * sc.noise(40.0)[..., None])
yy = np.linspace(0, 1, PH, dtype=np.float32).reshape(-1, 1)
im = finish(sc, alb, hmap, np.where(screen > 0, 0, body), 0.1, dust=0.008,
            extra=lambda img: img * (1 - 0.07 * (yy ** 2))[..., None])
bandT, bandB, bandL = int(round((0.022 + MG) * sy)), int(round((0.058 + MG) * sy)), int(round((0.022 + MG) * sx))
save(im.crop((0, 0, PW, bandT)), "desk_top_ca.png", (2048, 32))
save(im.crop((0, PH - bandB, PW, PH)), "desk_bottom_ca.png", (2048, 64))
save(im.crop((0, int(round(0.022 * sy)), bandL, PH - int(round(0.058 * sy)))), "desk_left_ca.png", (32, 512))
save(im.crop((PW - bandL, int(round(0.022 * sy)), PW, PH - int(round(0.058 * sy)))), "desk_right_ca.png", (32, 512))
im.save(os.path.join(OUT, "desk_monitor_reference.png"))

# ================= AYAK (boyun + taban) =================
sw, shh = 0.26, 0.044
PW, PH = int(round(sw * sx)), int(round(shh * sy))
sc = Scene(PW, PH, 20261111)
ux = lambda v: v * sx
uy = lambda v: v * sy
neck = sc.rr(ux(0.13 - 0.032), uy(0.0), 0.064 * sx, 0.034 * sy, 0.002 * sx)
nin = sc.rr(ux(0.13 - 0.012), uy(0.008), 0.024 * sx, 0.026 * sy, 0.002 * sx)
base = sc.rr(0, uy(0.028), PW, 0.016 * sy, 0.008 * sx)
mask = np.maximum(neck, base)
grain = sc.noise(0.8) * 0.6 + sc.noise(1.7) * 0.35
hmap = grain * 0.10 + blur(neck, 1.6) * 3.0 - blur(nin, 1.2) * 2.0 + blur(base, 1.8) * 4.0
alb = col((0.115, 0.115, 0.125)) * np.ones((PH, PW, 1), np.float32)
alb = alb * (1 - nin[..., None] * 0.35)
im = finish(sc, alb, hmap, mask, 0.1)
save(im, "desk_stand_ca.png", (1024, 128))

# ================= KLAVYE =================
kw, kh = 0.42, 0.054
PW, PH = int(round(kw * sx)), int(round(kh * sy))
sc = Scene(PW, PH, 20261112)
ux = lambda v: v * sx
uy = lambda v: v * sy
bodyk = sc.rr(0, 0, PW, PH, 0.008 * sx)
keys = np.zeros((PH, PW), np.float32)
kcols = 14
keyW = (kw - 0.016) / kcols
rects = []
for r in range(3):
    for c in range(kcols):
        rects.append((0.008 + c * keyW + 0.0012, 0.006 + r * 0.0125, keyW - 0.0024, 0.0105))
rects.append((0.06, 0.0435, kw - 0.12, 0.0085))
for (x, y, ww, hh) in rects:
    keys = np.maximum(keys, sc.rr(ux(x), uy(y), ww * sx, hh * sy, 0.0015 * sx))
grain = sc.noise(0.8) * 0.6 + sc.noise(1.7) * 0.35
hmap = grain * 0.10 + blur(bodyk, 2.0) * 3.0 + blur(keys, 0.9) * 3.5
alb = col((0.062, 0.062, 0.072)) * np.ones((PH, PW, 1), np.float32)
alb = alb * (1 - keys[..., None]) + col((0.17, 0.17, 0.19)) * keys[..., None]
# silik tus yazilari
leg = Image.new("L", (PW, PH), 0)
d = ImageDraw.Draw(leg)
try:
    f = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", max(6, int(0.0072 * sy)))
except Exception:
    f = ImageFont.load_default()
letters = ["1234567890-=<>", "QWERTYUIOPĞÜ[", "ASDFGHJKLŞİ;'"]
for r in range(3):
    for c in range(kcols):
        ch = letters[r][c] if c < len(letters[r]) else ""
        if ch:
            d.text((ux(0.008 + c * keyW + 0.0012 + 0.0035), uy(0.006 + r * 0.0125 + 0.0018)), ch, fill=150, font=f)
legn = np.asarray(leg, np.float32) / 255.0
def kb_extra(img):
    return img + legn[..., None] * col((0.5, 0.5, 0.55)) * 0.35
im = finish(sc, alb, hmap, bodyk, 0.1, extra=kb_extra)
save(im, "desk_keyboard_ca.png", (1024, 128))

# ================= FARE =================
mw, mh = 0.026, 0.044
PW, PH = int(round(mw * sx)), int(round(mh * sy))
sc = Scene(PW, PH, 20261113)
mm = sc.rr(0, 0, PW, PH, 0.011 * sx)
div = np.zeros((PH, PW), np.float32); div[:int(0.017 * sy), int(PW / 2) - 1:int(PW / 2) + 1] = 1
grain = sc.noise(0.8) * 0.6 + sc.noise(1.7) * 0.35
hmap = grain * 0.10 + blur(mm, 2.0) * 4.0 - blur(div, 0.8) * 2.0
alb = col((0.1, 0.1, 0.11)) * np.ones((PH, PW, 1), np.float32)
im = finish(sc, alb, hmap, mm, 0.1)
save(im, "desk_mouse_ca.png", (64, 128))
print("masa basi dokulari tamam")
