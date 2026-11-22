#!/usr/bin/env python3
"""Acha vídeos para incorporar na página. YouTube por busca ou canal (yt-dlp); Instagram por links de post.

  buscar-videos.py --youtube "nome do cantor ao vivo" --max 6
  buscar-videos.py --youtube https://www.youtube.com/@canal --max 6
  buscar-videos.py --instagram https://www.instagram.com/p/XXXX/ https://www.instagram.com/reel/YYYY/
Saída: JSON [{plataforma, titulo, url, embed, html}]. Só fonte pública.
"""
import argparse, json, re, subprocess, sys, shutil
p = argparse.ArgumentParser(); p.add_argument("--youtube"); p.add_argument("--max", type=int, default=6); p.add_argument("--instagram", nargs="*", default=[]); a = p.parse_args()
out = []
if a.youtube:
    if not shutil.which("yt-dlp"): sys.exit("yt-dlp não instalado (rode: python3 instalar.py ferramentas)")
    alvo = a.youtube if a.youtube.startswith("http") else f"ytsearch{a.max}:{a.youtube}"
    if a.youtube.startswith("http") and "/videos" not in a.youtube and ("/@" in a.youtube or "/channel/" in a.youtube): alvo = a.youtube.rstrip("/") + "/videos"
    r = subprocess.run(["yt-dlp", "--flat-playlist", "--playlist-end", str(a.max), "-J", alvo], capture_output=True, text=True, timeout=120)
    if r.returncode: sys.exit("yt-dlp falhou: " + r.stderr[-300:])
    for e in (json.loads(r.stdout).get("entries") or [])[: a.max]:
        vid = e.get("id")
        if not vid or len(vid) != 11: continue
        out.append({"plataforma": "youtube", "titulo": e.get("title"), "url": f"https://www.youtube.com/watch?v={vid}", "embed": f"https://www.youtube.com/embed/{vid}",
                    "html": f'<iframe src="https://www.youtube.com/embed/{vid}" title="{(e.get("title") or "").replace(chr(34), "")}" loading="lazy" allowfullscreen style="width:100%;aspect-ratio:16/9;border:0"></iframe>'})
for u in a.instagram:
    m = re.search(r"instagram\.com/(?:[\w.]+/)?(p|reel|tv)/([\w-]+)", u)
    if not m: continue
    emb = f"https://www.instagram.com/{m.group(1)}/{m.group(2)}/embed"
    out.append({"plataforma": "instagram", "titulo": None, "url": u, "embed": emb,
                "html": f'<iframe src="{emb}" loading="lazy" allowfullscreen style="width:100%;max-width:540px;height:640px;border:0"></iframe>'})
print(json.dumps(out, ensure_ascii=False, indent=1))
