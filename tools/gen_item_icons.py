# TC2 envanter / arsenal ikonlari (256x128): tablet, kask kamerasi, seviye kartlari. Dort kat ornekleme + golge + isik/gradyan + ince tane.
import os, sys, math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = sys.argv[1] if len(sys.argv) > 1 else "icons"
os.makedirs(OUT, exist_ok=True)
S = 4
W, H = 256 * S, 128 * S
rng = np.random.default_rng(777)
FB = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FM = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"

def font(path, px): return ImageFont.truetype(path, int(px))

def canvas(): return Image.new("RGBA", (W, H), (0, 0, 0, 0))

def rr_mask(box, r):
    m = Image.new("L", (W, H), 0)
    ImageDraw.Draw(m).rounded_rectangle(box, radius=r, fill=255)
    return m

def gradient(box, top, bottom, mask):
    """dikey gradyan dolgu (maske icinde)"""
    x0, y0, x1, y1 = [int(v) for v in box]
    g = np.zeros((H, W, 4), np.float32)
    t = np.clip((np.arange(H) - y0) / max(1, (y1 - y0)), 0, 1).reshape(-1, 1, 1)
    top_ = np.array(list(top) + [1], np.float32); bot_ = np.array(list(bottom) + [1], np.float32)
    g[:] = top_ * (1 - t) + bot_ * t
    img = Image.fromarray((g * 255).astype(np.uint8), "RGBA")
    img.putalpha(mask)
    return img

def paste(base, layer):
    base.alpha_composite(layer)

def shadow(base, mask, offset=(10, 18), blur=22, alpha=0.55):
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    a = mask.filter(ImageFilter.GaussianBlur(blur)).point(lambda v: int(v * alpha))
    sh.putalpha(a)
    sh = sh.transform(sh.size, Image.AFFINE, (1, 0, -offset[0], 0, 1, -offset[1]))
    base.alpha_composite(sh)

def grain(img, amp=7):
    arr = np.asarray(img, np.int16).copy()
    n = rng.normal(0, amp, (H, W, 1))
    arr[..., :3] = np.clip(arr[..., :3] + n, 0, 255)
    return Image.fromarray(arr.astype(np.uint8), "RGBA")

def finish(base, name):
    out = base.resize((256, 128), Image.LANCZOS)
    out.save(os.path.join(OUT, name))

def highlight_edge(base, mask, light=0.35, dark=0.45, width=5):
    """ust-sol kenar isigi, alt-sag kenar golgesi (kabartma)"""
    m = np.asarray(mask, np.float32) / 255.0
    sh_x = np.roll(m, width, 1); sh_y = np.roll(m, width, 0)
    hl = np.clip(m - np.roll(np.roll(m, width, 0), width, 1), 0, 1)        # ust-sol dis kenar
    dk = np.clip(m - np.roll(np.roll(m, -width, 0), -width, 1), 0, 1)
    lay = np.zeros((H, W, 4), np.float32)
    lay[..., :3] = 1.0; lay[..., 3] = hl * light
    layd = np.zeros((H, W, 4), np.float32); layd[..., 3] = dk * dark
    base.alpha_composite(Image.fromarray((lay * 255).astype(np.uint8), "RGBA"))
    base.alpha_composite(Image.fromarray((layd * 255).astype(np.uint8), "RGBA"))

# ================= TABLET =================
def tablet():
    im = canvas()
    box = (70, 52, 954, 468)   # 884 x 416
    body = rr_mask(box, 64)
    shadow(im, body)
    paste(im, gradient(box, (0.2, 0.24, 0.16), (0.1, 0.125, 0.08), body))
    # kose koruyucular (koyu)
    d = ImageDraw.Draw(im)
    for (cx, cy, sx, sy) in [(box[0], box[1], 1, 1), (box[2], box[1], -1, 1), (box[0], box[3], 1, -1), (box[2], box[3], -1, -1)]:
        bm = rr_mask((min(cx, cx + sx * 150), min(cy, cy + sy * 150), max(cx, cx + sx * 150), max(cy, cy + sy * 150)), 54)
        corner = gradient(box, (0.07, 0.085, 0.055), (0.04, 0.05, 0.03), bm)
        m2 = Image.new("L", (W, H), 0); m2.paste(bm, (0, 0), body)
        corner.putalpha(Image.fromarray(np.minimum(np.asarray(bm), np.asarray(body))))
        paste(im, corner)
    highlight_edge(im, body)
    # ust tuslar
    d = ImageDraw.Draw(im)
    for (x, w_) in [(560, 70), (650, 36), (704, 56)]:
        d.rectangle([x, box[1] - 11, x + w_, box[1] + 4], fill=(18, 22, 14, 255))
    # ekran cercevesi + ekran
    bez = rr_mask((118, 96, 906, 424), 28)
    paste(im, gradient((118, 96, 906, 424), (0.02, 0.02, 0.02), (0.03, 0.03, 0.03), bez))
    scr = rr_mask((160, 118, 884, 402), 12)
    scr_img = gradient((160, 118, 884, 402), (0.03, 0.12, 0.07), (0.01, 0.05, 0.03), scr)
    sd = ImageDraw.Draw(scr_img)
    for gx in range(180, 884, 90): sd.line([(gx, 128), (gx, 396)], fill=(30, 110, 60, 120), width=2)
    for gy in range(140, 402, 70): sd.line([(166, gy), (878, gy)], fill=(30, 110, 60, 120), width=2)
    sd.ellipse([440, 230, 468, 258], fill=(60, 140, 255, 255)); sd.ellipse([640, 190, 668, 218], fill=(255, 60, 60, 255))
    sd.rectangle([160, 118, 884, 150], fill=(0, 70, 25, 255)); sd.text((176, 124), "TC2 SAHA", font=font(FM, 20), fill=(90, 255, 130, 255))
    paste(im, scr_img)
    # cam yansimasi
    refl = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(refl).polygon([(160, 118), (520, 118), (320, 402), (160, 402)], fill=(255, 255, 255, 22))
    refl.putalpha(Image.fromarray(np.minimum(np.asarray(refl.split()[3]), np.asarray(scr))))
    paste(im, refl)
    d = ImageDraw.Draw(im)
    d.ellipse([86, 250, 104, 268], fill=(10, 10, 14, 255))          # kamera
    for k in range(4): d.ellipse([470 + k * 28, 440, 482 + k * 28, 452], fill=(170, 135, 55, 255))  # pogo
    highlight_edge(im, bez, 0.15, 0.25, 3)
    return grain(im)

# ================= KASK KAMERASI =================
def helmetcam():
    im = canvas()
    # montaj plakasi
    plate = rr_mask((320, 360, 704, 440), 26)
    shadow(im, plate, (8, 14), 14, 0.5)
    paste(im, gradient((320, 360, 704, 440), (0.27, 0.27, 0.28), (0.13, 0.13, 0.14), plate))
    d = ImageDraw.Draw(im)
    for x in range(360, 680, 44): d.rounded_rectangle([x, 382, x + 26, 420], radius=8, fill=(12, 12, 14, 255))
    # govde
    box = (232, 96, 792, 372)
    body = rr_mask(box, 60)
    shadow(im, body)
    paste(im, gradient(box, (0.16, 0.16, 0.17), (0.055, 0.055, 0.06), body))
    highlight_edge(im, body, 0.4, 0.5)
    # lens
    cx, cy = 512, 232
    ring = Image.new("L", (W, H), 0); ImageDraw.Draw(ring).ellipse([cx - 118, cy - 118, cx + 118, cy + 118], fill=255)
    paste(im, gradient((0, cy - 118, 0, cy + 118), (0.42, 0.42, 0.45), (0.1, 0.1, 0.11), ring))
    glass = Image.new("L", (W, H), 0); ImageDraw.Draw(glass).ellipse([cx - 88, cy - 88, cx + 88, cy + 88], fill=255)
    paste(im, gradient((0, cy - 88, 0, cy + 88), (0.03, 0.04, 0.09), (0.0, 0.0, 0.02), glass))
    inner = Image.new("L", (W, H), 0); ImageDraw.Draw(inner).ellipse([cx - 48, cy - 48, cx + 48, cy + 48], fill=255)
    paste(im, gradient((0, cy - 48, 0, cy + 48), (0.02, 0.02, 0.05), (0.06, 0.03, 0.12), inner))
    hl = Image.new("RGBA", (W, H), (0, 0, 0, 0)); hd = ImageDraw.Draw(hl)
    hd.ellipse([cx - 62, cy - 70, cx - 14, cy - 34], fill=(255, 255, 255, 90)); hd.ellipse([cx + 22, cy + 26, cx + 52, cy + 44], fill=(120, 170, 255, 70))
    hl.putalpha(Image.fromarray(np.minimum(np.asarray(hl.split()[3]), np.asarray(glass))))
    paste(im, hl)
    d = ImageDraw.Draw(im)
    d.ellipse([692, 124, 716, 148], fill=(200, 30, 30, 255)); d.ellipse([697, 129, 705, 137], fill=(255, 160, 150, 255))   # LED
    d.text((262, 112), "TC2", font=font(FB, 30), fill=(120, 120, 126, 255))
    d.rounded_rectangle([760, 190, 790, 250], radius=8, fill=(10, 10, 12, 255))                                           # dugme
    return grain(im)

# ================= KARTLAR =================
def card(name, base_top, base_bottom, band, band_text, level_text, text_col, chip=True):
    im = canvas()
    box = (118, 12, 138 + 780 - 20, 12 + 488)   # ~ 780 x 488 (1.6:1)
    box = (112, 18, 912, 494)
    body = rr_mask(box, 44)
    shadow(im, body, (8, 14), 16, 0.5)
    paste(im, gradient(box, base_top, base_bottom, body))
    d = ImageDraw.Draw(im)
    # bant
    bandm = np.minimum(np.asarray(rr_mask((112, 18, 912, 140), 44)), np.asarray(body))
    bl = gradient((112, 18, 912, 140), band[0], band[1], Image.fromarray(bandm))
    d.rectangle([112, 100, 912, 140], fill=(0, 0, 0, 0))
    paste(im, bl)
    d = ImageDraw.Draw(im)
    d.rectangle([112, 100, 912, 140], fill=tuple(int(v * 255) for v in band[1]) + (255,))
    d.text((150, 52), "TC2 ACCESS", font=font(FB, 54), fill=band_text)
    d.text((660, 62), level_text, font=font(FB, 40), fill=band_text)
    # foto kutusu + siluet
    d.rounded_rectangle([150, 190, 350, 450], radius=14, fill=(40, 42, 46, 255))
    d.ellipse([205, 220, 295, 310], fill=(95, 98, 104, 255)); d.rounded_rectangle([180, 320, 320, 440], radius=40, fill=(95, 98, 104, 255))
    # yazi cubuklari
    for i, (w_, y) in enumerate([(300, 200), (240, 250), (270, 300)]):
        d.rounded_rectangle([390, y, 390 + w_, y + 24], radius=10, fill=tuple(int(c * 255) for c in text_col) + (210,))
    d.text((390, 352), level_text, font=font(FB, 64), fill=tuple(int(c * 255) for c in text_col) + (255,))
    if chip:
        cm = (700, 190, 850, 290)
        d.rounded_rectangle(cm, radius=18, fill=(196, 160, 70, 255))
        for k in range(1, 4): d.line([cm[0] + 8, cm[1] + k * 25, cm[2] - 8, cm[1] + k * 25], fill=(120, 95, 35, 255), width=3)
        d.line([775, cm[1] + 6, 775, cm[3] - 6], fill=(120, 95, 35, 255), width=3)
    # barkod
    x = 700
    for k in range(26):
        w_ = int(rng.choice([4, 6, 9])); d.rectangle([x, 395, x + w_, 450], fill=tuple(int(c * 255) for c in text_col) + (230,)); x += w_ + int(rng.choice([4, 6]))
        if x > 880: break
    # parlama
    gl = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(gl).polygon([(112, 18), (520, 18), (330, 494), (112, 494)], fill=(255, 255, 255, 26))
    gl.putalpha(Image.fromarray(np.minimum(np.asarray(gl.split()[3]), np.asarray(body))))
    paste(im, gl)
    highlight_edge(im, body, 0.3, 0.4, 4)
    return grain(im, 5)

icons = {
    "icon_tablet_ca.png": tablet(),
    "icon_helmetcam_ca.png": helmetcam(),
    "icon_card_red_ca.png": card("red", (0.9, 0.9, 0.88), (0.66, 0.66, 0.64), ((0.82, 0.14, 0.12), (0.55, 0.07, 0.06)), (255, 255, 255, 255), "LEVEL 1", (0.18, 0.18, 0.2)),
    "icon_card_blue_ca.png": card("blue", (0.9, 0.9, 0.88), (0.66, 0.66, 0.64), ((0.14, 0.36, 0.82), (0.07, 0.2, 0.55)), (255, 255, 255, 255), "LEVEL 2", (0.18, 0.18, 0.2)),
    "icon_card_gold_ca.png": card("gold", (0.11, 0.11, 0.12), (0.04, 0.04, 0.045), ((0.86, 0.7, 0.28), (0.55, 0.42, 0.12)), (30, 22, 8, 255), "LEVEL 3", (0.86, 0.7, 0.3)),
    "icon_cac_ca.png": card("cac", (0.78, 0.8, 0.82), (0.55, 0.57, 0.6), ((0.2, 0.3, 0.5), (0.1, 0.17, 0.32)), (255, 255, 255, 255), "CAC", (0.15, 0.17, 0.22)),
}
for name, im in icons.items():
    finish(im, name)
print("ikonlar tamam", list(icons))
