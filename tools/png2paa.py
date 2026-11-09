# PNG(RGBA) -> Arma 3 .paa (DXT5, sikistirilmamis mip zinciri). Bagimsiz dogrulama icin okuyucu da var.
import io, struct, sys
from PIL import Image

def dxt5_blocks(img):
    """RGBA PIL imaj -> ham DXT5 blok verisi (Pillow DDS yazici)"""
    w, h = img.size
    pw, ph = max(4, w), max(4, h)
    if (pw, ph) != (w, h):                      # 4x4'ten kucuk mipler: kenar kopyalayarak 4x4'e doldur
        big = Image.new("RGBA", (pw, ph))
        for y in range(ph):
            for x in range(pw):
                big.putpixel((x, y), img.getpixel((min(x, w - 1), min(y, h - 1))))
        img = big
    buf = io.BytesIO()
    img.save(buf, "DDS", pixel_format="DXT5")
    data = buf.getvalue()
    assert data[:4] == b"DDS " and data[84:88] == b"DXT5", "beklenmeyen DDS"
    body = data[128:]
    need = ((pw + 3) // 4) * ((ph + 3) // 4) * 16
    assert len(body) == need, (len(body), need)
    return body

def write_paa(img, path):
    img = img.convert("RGBA")
    W, H = img.size
    mips = []
    cur = img
    while True:
        mips.append(cur)
        if cur.width == 1 and cur.height == 1:
            break
        cur = img.resize((max(1, cur.width // 2), max(1, cur.height // 2)), Image.LANCZOS)
        img_ = cur
    datas = [dxt5_blocks(m) for m in mips]
    px = list(img.resize((1, 1), Image.BOX).getpixel((0, 0)))
    mx = [max(c) for c in zip(*[img.getpixel((x, y)) for x in range(0, W, max(1, W // 16)) for y in range(0, H, max(1, H // 16))])]
    avg = struct.pack("<4B", px[2], px[1], px[0], px[3])      # BGRA
    mxc = struct.pack("<4B", mx[2], mx[1], mx[0], mx[3])
    def tag(name, payload):
        return b"GGAT" + name[::-1].encode() + struct.pack("<I", len(payload)) + payload
    header_len = 2 + (12 + 4) + (12 + 4) + (12 + 4) + (12 + 64) + 2
    offs, pos = [], header_len
    for d in datas:
        offs.append(pos)
        pos += 2 + 2 + 3 + len(d)
    offs += [0] * (16 - len(offs))
    out = bytearray()
    out += struct.pack("<H", 0xFF05)                         # DXT5
    out += tag("AVGC", avg) + tag("MAXC", mxc) + tag("FLAG", struct.pack("<I", 1)) + tag("OFFS", struct.pack("<16I", *offs))
    out += struct.pack("<H", 0)                              # palet yok
    assert len(out) == header_len, (len(out), header_len)
    for m, d in zip(mips, datas):
        out += struct.pack("<HH", m.width, m.height) + struct.pack("<I", len(d))[:3] + d
    out += b"\x00" * 6                                       # son
    open(path, "wb").write(bytes(out))
    return len(out), len(mips)

def read_paa(path):
    b = open(path, "rb").read()
    t = struct.unpack_from("<H", b, 0)[0]
    assert t == 0xFF05, hex(t)
    pos = 2
    tags = {}
    while b[pos:pos + 4] == b"GGAT":
        name = b[pos + 4:pos + 8][::-1].decode()
        ln = struct.unpack_from("<I", b, pos + 8)[0]
        tags[name] = b[pos + 12:pos + 12 + ln]
        pos += 12 + ln
    npal = struct.unpack_from("<H", b, pos)[0]; pos += 2 + 3 * npal
    offs = struct.unpack("<16I", tags["OFFS"])
    mips = []
    while True:
        wv, hv = struct.unpack_from("<HH", b, pos)
        if wv == 0 and hv == 0:
            break
        size = int.from_bytes(b[pos + 4:pos + 7], "little")
        assert not (wv & 0x8000), "LZO sikistirma beklenmiyordu"
        mips.append((wv, hv, pos, b[pos + 7:pos + 7 + size]))
        pos += 7 + size
    assert [m[2] for m in mips] == [o for o in offs if o], "OFFS tablosu uyumsuz"
    return tags, mips

def decode_mip(w, h, data):
    pw, ph = max(4, w), max(4, h)
    hdr = bytearray(128)
    hdr[0:4] = b"DDS "
    struct.pack_into("<7I", hdr, 4, 124, 0x1 | 0x2 | 0x4 | 0x1000 | 0x80000, ph, pw, len(data), 0, 0)
    struct.pack_into("<I", hdr, 76, 32); struct.pack_into("<I", hdr, 80, 4); hdr[84:88] = b"DXT5"
    struct.pack_into("<I", hdr, 108, 0x1000)
    im = Image.open(io.BytesIO(bytes(hdr) + data)).convert("RGBA")
    return im.crop((0, 0, w, h))

if __name__ == "__main__":
    src, dst = sys.argv[1], sys.argv[2]
    n, m = write_paa(Image.open(src), dst)
    tags, mips = read_paa(dst)
    top = decode_mip(*mips[0][:2], mips[0][3])
    ref = Image.open(src).convert("RGBA")
    import numpy as np
    err = np.abs(np.asarray(top, np.int16) - np.asarray(ref, np.int16)).mean()
    print(dst, "bytes", n, "mips", m, "ort.hata", round(float(err), 2))
