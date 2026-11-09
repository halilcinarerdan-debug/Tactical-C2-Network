# TC2 saha tableti dokulari: proseduel kabartma (heightmap + isik) ile uretilir, DXT5 .paa olarak yazilir.
# Cikti: data/tab_{tl,tr,bl,br,top,bottom,left,right}_ca.paa (+ ayni adli .png kaynak/onizleme)
import io, math, os, struct, sys
import numpy as np
from PIL import Image, ImageFilter, ImageDraw

OUT = sys.argv[1] if len(sys.argv) > 1 else "tex_out"
os.makedirs(OUT, exist_ok=True)
rng = np.random.default_rng(20261109)

# ---- Referans GUI olcegi: 1.5 x 0.9 birim, 1920x1080 -> sx=1280, sy=1200; ic cozunurluk 1.6x ----
SS = 1.6
sx, sy = 1280 * SS, 1200 * SS
ratio = (0.9 / 1.5) * (1920 / 1080)
w, h = 0.7 * 1.5, 0.64 * 0.9          # ekran (GUI birimi)
X0, Y0 = -0.058, -0.042               # kasa sol-ust (ekranin sol-ustune gore)
W0, H0 = w + 0.116, h + 0.084
PW, PH = int(round(W0 * sx)), int(round(H0 * sy))
def ux(v): return (v - X0) * sx       # x birimi -> piksel (kasa bolgesi icinde)
def uy(v): return (v - Y0) * sy

def blur(a, s):
    """gaussian bulaniklastirma (numpy FFT, kenar yinelemeli dolgu)"""
    a = np.asarray(a, np.float32)
    pad = int(3 * s) + 2
    p = np.pad(a, pad, mode="edge")
    fy = np.fft.fftfreq(p.shape[0]).astype(np.float32).reshape(-1, 1)
    fx = np.fft.rfftfreq(p.shape[1]).astype(np.float32).reshape(1, -1)
    k = np.exp(-2 * (math.pi ** 2) * (s ** 2) * (fy ** 2 + fx ** 2)).astype(np.float32)
    out = np.fft.irfft2(np.fft.rfft2(p) * k, s=p.shape)
    return out[pad:-pad, pad:-pad].astype(np.float32)

def rrect_mask(x, y, rw, rh, r, ss=2):
    """yuvarlak kose maskesi (0..1), ss kat ornekleme ile kenar yumusatma; birimler piksel"""
    W, H = PW * ss, PH * ss
    m = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle([x * ss, y * ss, (x + rw) * ss - 1, (y + rh) * ss - 1], radius=r * ss, fill=255)
    m = m.resize((PW, PH), Image.LANCZOS)
    return np.asarray(m, dtype=np.float32) / 255.0

# --- sekiller (piksel) ---
case = rrect_mask(0, 0, PW, PH, 0.036 * sx)
lip = rrect_mask(ux(-0.03), uy(-0.024), (w + 0.06) * sx, (h + 0.048) * sy, 0.02 * sx)
bez = rrect_mask(ux(-0.018), uy(-0.0155), (w + 0.036) * sx, (h + 0.031) * sy, 0.012 * sx)
bs = 0.082 * sx; bsv = 0.082 * ratio * sy
bump = np.zeros((PH, PW), np.float32)
for (bx, by) in [(0, 0), (PW - bs, 0), (0, PH - bsv), (PW - bs, PH - bsv)]:
    bump = np.maximum(bump, rrect_mask(bx, by, bs, bsv, 0.036 * sx))
bump *= case
screen = np.zeros((PH, PW), np.float32)
screen[int(uy(0)):int(uy(h)), int(ux(0)):int(ux(w))] = 1.0

# --- yukseklik haritasi (piksel olcegi): ince, duzgun kaucuk tanesi + kabartma ---
def noise(s):
    n = blur(rng.standard_normal((PH, PW)).astype(np.float32), s)
    return n / (n.std() + 1e-6)
grain = noise(0.9) * 0.6 + noise(1.8) * 0.4 + noise(5.0) * 0.12
H_feat = blur(bump, 2.5) * 6.0 + blur(lip * (1 - bez), 1.6) * 4.0 - blur(bez, 2.0) * 5.0
hmap = grain * 0.35 + H_feat
gy, gx = np.gradient(hmap)
shade = 0.7 + (-gx * 0.5 - gy * 0.7) * 0.5
shade = np.clip(shade, 0.25, 1.45)

def col(c): return np.array(c, np.float32).reshape(1, 1, 3)
alb = col((0.2, 0.235, 0.16)) * np.ones((PH, PW, 1), np.float32)
alb = alb * (1 - bump[..., None]) + col((0.095, 0.112, 0.075)) * bump[..., None]
lipm = (lip * (1 - bez) * (1 - bump))[..., None]
alb = alb * (1 - lipm) + col((0.15, 0.18, 0.12)) * lipm
bezm = bez[..., None]
alb = alb * (1 - bezm) + col((0.012, 0.012, 0.012)) * bezm
# cok yumusak renk degisimi (tek olcek, dusuk genlik)
mott = noise(26.0)
alb = alb * (1 + 0.07 * mott[..., None])
img = alb * shade[..., None]

# toz: yalnizca YUKARI bakan yuzeylerde ince, duzgun film (isik alan kabartmalarda hafif acilma) + alta dogru hafif koyulasma
up = np.clip(-gy * 0.9, 0, 1)
img += (up * 0.5)[..., None] * col((0.5, 0.45, 0.34)) * 0.22
img += 0.022 * col((0.6, 0.54, 0.42))
yy = np.linspace(0, 1, PH, dtype=np.float32).reshape(-1, 1)
img *= (1 - 0.14 * (yy ** 2))[..., None]
# ortam golgelemesi: kabartma diplerinde hafif kir
ao = np.clip(blur(hmap, 5) - hmap, 0, None)
img *= (1 - np.clip(ao * 0.06, 0, 0.25))[..., None]
# kenar asinmasi: YALNIZ kose koruyucularin dis kenarinda, yumusak
dist = blur(case, 2.5)
rim = np.clip((0.9 - dist) / 0.4, 0, 1) * case * bump
wn = noise(3.0)
wear = np.clip(rim * (0.5 + 0.5 * wn), 0, 1)
img = img * (1 - 0.3 * wear[..., None]) + col((0.4, 0.44, 0.35)) * 0.3 * wear[..., None]
# birkac ince, silik cizik (yalnizca kose koruyucu bolgelerinde)
sc = Image.new("L", (PW, PH), 0)
d = ImageDraw.Draw(sc)
for i in range(14):
    cx_, cy_ = (rng.integers(0, int(bs)) if rng.random() < 0.5 else rng.integers(PW - int(bs), PW)), (rng.integers(0, int(bsv)) if rng.random() < 0.5 else rng.integers(PH - int(bsv), PH))
    L = int(rng.choice([18, 30, 46]) * SS / 1.6)
    if rng.random() < 0.5:
        d.line([cx_, cy_, cx_ + L, cy_ + int(rng.integers(-1, 2))], fill=int(rng.choice([40, 70])), width=1)
    else:
        d.line([cx_, cy_, cx_ + int(rng.integers(-1, 2)), cy_ + L], fill=int(rng.choice([40, 70])), width=1)
scn = blur(np.asarray(sc, np.float32) / 255.0, 0.6)
img = img + scn[..., None] * col((0.5, 0.53, 0.46)) * 0.5

img = np.clip(img, 0, 1)
alpha = np.where(screen > 0, 0, case)   # ekran bolgesi seffaf (icerik zaten ustunde)
rgba = np.dstack([img, alpha]).astype(np.float32)
ref = Image.fromarray((rgba * 255 + 0.5).astype(np.uint8), "RGBA")
ref.save(os.path.join(OUT, "tab_reference.png"))

# ---- dilimleme ----
cs_px, csv_px = int(round(bs)), int(round(bsv))
bandL, bandT = int(round(0.058 * sx)), int(round(0.042 * sy))
pieces = {
    "tl": (ref.crop((0, 0, cs_px, csv_px)), (256, 256)),
    "tr": (ref.crop((PW - cs_px, 0, PW, csv_px)), (256, 256)),
    "bl": (ref.crop((0, PH - csv_px, cs_px, PH)), (256, 256)),
    "br": (ref.crop((PW - cs_px, PH - csv_px, PW, PH)), (256, 256)),
    "top": (ref.crop((cs_px, 0, PW - cs_px, bandT)), (2048, 64)),
    "bottom": (ref.crop((cs_px, PH - bandT, PW - cs_px, PH)), (2048, 64)),
    "left": (ref.crop((0, csv_px, bandL, PH - csv_px)), (128, 512)),
    "right": (ref.crop((PW - bandL, csv_px, PW, PH - csv_px)), (128, 512)),
}
for k, (im, size) in pieces.items():
    im.resize(size, Image.LANCZOS).save(os.path.join(OUT, "tab_%s_ca.png" % k))
print("pieces", {k: v[0].size for k, v in pieces.items()})
