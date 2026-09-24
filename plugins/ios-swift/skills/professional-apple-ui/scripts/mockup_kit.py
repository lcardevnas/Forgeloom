#!/usr/bin/env python3
"""HTML side of the style system: the style gallery and mockup starters.

  mockup_kit.py gallery <out.html> [styles.json]
      One page with every style, light and dark side by side, to pick from
      (the prebuilt one is assets/style-gallery.html).
  mockup_kit.py starter <style-id | style.json> <out.html> [--platform macos|ios] [--title T]
      A mockup starter: the style's tokens as CSS variables, the component
      classes (card, hero, chip, button, stat, row, bar…), a light/dark toggle,
      and an empty window (macOS 1280×800) or phone frame (iOS 393×852).
  mockup_kit.py css <style-id | style.json>
      Just the :root / [data-theme=dark] token blocks, to paste into a mockup.
  mockup_kit.py export <style-id>
      A preset as JSON, to save as a project's docs/ui-style.json.
"""
import sys
sys.dont_write_bytecode = True  # keep the plugin folder free of __pycache__
import html
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
# The plugin's `knowledge` link points at knowledge/ios-swift, so this resolves both
# in an installed plugin and in a Forgeloom checkout.
STYLES = os.path.join(HERE, "..", "..", "..", "knowledge", "design-system", "styles", "styles.json")

FONTS = {
    "rounded": ('ui-rounded, "SF Pro Rounded", -apple-system, system-ui, sans-serif', 'ui-rounded, "SF Pro Rounded", -apple-system, system-ui, sans-serif'),
    "default": ('-apple-system, system-ui, "SF Pro Text", sans-serif', '-apple-system, system-ui, "SF Pro Display", sans-serif'),
    "serif": ('-apple-system, system-ui, sans-serif', 'ui-serif, "New York", Georgia, serif'),
}

ICONS = '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@3.19.0/dist/tabler-icons.min.css">'


def write(out, page):
    """Writes a page, creating its folder (a new project has no mockups folder yet)."""
    folder = os.path.dirname(os.path.abspath(out))
    os.makedirs(folder, exist_ok=True)
    with open(out, "w") as f:
        f.write(page)
    print(out)


def load_style(ref, path=STYLES):
    if ref.endswith(".json") and os.path.exists(ref):
        data = json.load(open(ref))
        return data["styles"][0] if "styles" in data else data
    for s in json.load(open(path))["styles"]:
        if s["id"] == ref:
            return s
    sys.exit(f"Unknown style: {ref}")


def kebab(name):
    return "".join("-" + c.lower() if c.isupper() else c for c in name)


def token_block(tokens, style, scope=""):
    lines = [f"--{kebab(k)}:{v};" for k, v in tokens.items()]
    body, head = FONTS[style["font"]]
    r = style["radius"]
    lines += [f"--font:{body};", f"--font-head:{head};",
              f"--r-hero:{r['hero']}px;", f"--r-card:{r['card']}px;", f"--r-tile:{r['tile']}px;", f"--r-thumb:{r['thumbnail']}px;"]
    return "\n  ".join(lines)


def css(style, root=":root", dark="[data-theme=dark]"):
    return (f"{root}{{\n  {token_block(style['light'], style)}\n}}\n"
            f"{dark}{{\n  {token_block(style['dark'], style)}\n}}\n")


COMPONENTS = """
*{box-sizing:border-box;margin:0}
body{font-family:var(--font);color:var(--text);background:var(--canvas);-webkit-font-smoothing:antialiased}
h1,h2,h3,.head{font-family:var(--font-head)}
.card{background:var(--card);border-radius:var(--r-card);padding:22px}
.hero{background:var(--hero);color:var(--on-hero);border-radius:var(--r-hero);padding:26px}
.hero .chip{background:var(--chip-on-hero);color:var(--on-hero)}
.chip{display:inline-flex;align-items:center;gap:6px;font-size:12px;font-weight:600;padding:5px 12px;border-radius:99px;white-space:nowrap}
.chip.brand{background:var(--brand-tint);color:var(--on-brand-tint)}
.chip.info{background:var(--info);color:var(--on-info)}
.chip.plan{background:var(--plan);color:var(--on-plan)}
.chip.attention{background:var(--attention);color:var(--on-attention)}
.chip.danger{background:var(--danger);color:var(--on-danger)}
.btn{display:inline-flex;align-items:center;gap:6px;height:32px;padding:0 16px;border-radius:99px;font:600 13px var(--font);border:0;white-space:nowrap}
.btn.primary{background:var(--primary);color:var(--on-primary)}
.btn.secondary{background:var(--card);color:var(--text)}
.btn.ghost{background:var(--well);color:var(--text)} /* inside a card only: on the canvas or a toolbar it disappears */
.btn.danger{background:var(--danger);color:var(--on-danger)}
.search{display:flex;align-items:center;gap:8px;height:32px;border-radius:99px;background:var(--card);padding:0 14px;color:var(--text3);font-size:13px;white-space:nowrap;overflow:hidden}
.circle{width:40px;height:40px;border-radius:50%;display:grid;place-items:center;font-size:19px;flex:none}
.circle.brand{background:var(--brand-tint);color:var(--on-brand-tint)}
.circle.info{background:var(--info);color:var(--on-info)}
.circle.plan{background:var(--plan);color:var(--on-plan)}
.circle.attention{background:var(--attention);color:var(--on-attention)}
.num{font:700 28px/1 var(--font-head)}
.t1{font-size:15px;font-weight:600}
.t2{font-size:13px;color:var(--text2)}
.t3{font-size:12px;color:var(--text3)}
.bar{height:6px;border-radius:99px;background:var(--well);overflow:hidden}
.bar i{display:block;height:100%;border-radius:99px;background:var(--accent)}
.tile{border-radius:var(--r-tile);background:var(--well)}
.row{display:flex;align-items:center;gap:14px;padding:12px 0}
.row+.row{border-top:1px solid var(--line)}
"""


def preview(style, mode):
    """A small dashboard in one mode, for the gallery."""
    t = style["light" if mode == "light" else "dark"]
    return f"""
<div class="pv" data-theme="{mode}">
  <div class="side"><div class="nav sel"><b class="g">⌂</b>Home</div><div class="nav"><b class="g">✉</b>Inbox<span class="chip attention sm">3</span></div><div class="nav"><b class="g">▤</b>Projects</div></div>
  <div class="body">
    <div class="hi">Good morning</div><div class="t2">2 items need you today</div>
    <div class="grid">
      <div class="hero"><span class="chip"><b>✦</b>Next up</span><div class="h">Review 8 designs</div><div class="sm2">Autumn set, ready to pick</div><button class="btn primary" style="margin-top:12px">Start Review</button></div>
      <div class="card stat"><div class="circle info">◷</div><div class="num">12</div><div class="t2">Running</div></div>
      <div class="card stat"><div class="circle plan">✧</div><div class="num">40</div><div class="t2">Ideas</div></div>
    </div>
    <div class="card list">
      <div class="row"><div class="tile sq"></div><div style="flex:1"><div class="t1">Sticker pack</div><div class="bar"><i style="width:62%"></i></div></div><span class="chip brand"><b>✓</b>Done</span></div>
      <div class="row"><div class="tile sq"></div><div style="flex:1"><div class="t1">Wall art</div><div class="t2">3 of 6 steps</div></div><span class="chip info"><b>↻</b>Running</span></div>
      <div class="row"><div class="tile sq"></div><div style="flex:1"><div class="t1">Planner</div><div class="t2">Waiting for you</div></div><span class="chip attention"><b>!</b>Review</span></div>
      <div class="row"><div class="tile sq"></div><div style="flex:1"><div class="t1">Poster</div><div class="t2">Upload stopped</div></div><span class="chip danger"><b>✕</b>Failed</span></div>
    </div>
  </div>
</div>"""


def gallery(out, path=STYLES):
    styles = json.load(open(path))["styles"]
    blocks, cards = [], []
    for s in styles:
        sid = s["id"]
        blocks.append(css(s, f"#{sid} [data-theme=light]", f"#{sid} [data-theme=dark]"))
        swatches = "".join(f'<i style="background:{s["light"][k]}" title="{k}"></i>' for k in ("hero", "primary", "info", "plan", "attention", "danger", "canvas"))
        note = f'<p class="note">{html.escape(s["notes"])}</p>' if s.get("notes") else ""
        cards.append(f"""
<section class="style" id="{sid}">
  <header><div><h2>{html.escape(s['name'])}</h2><p>{html.escape(s['mood'])}</p>
  <p class="meta">{s['font'].capitalize()} type · cards {s['radius']['card']} pt · <code>{sid}</code></p>{note}</div>
  <div class="sw">{swatches}</div><button class="pick" onclick="pick('{sid}',this)">Use this style</button></header>
  <div class="pair">{preview(s, 'light')}{preview(s, 'dark')}</div>
</section>""")
    page = f"""<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Style Gallery</title>
<style>
{''.join(blocks)}
{COMPONENTS}
body{{background:#E9E9EC;color:#1d1d1f;font-family:-apple-system,system-ui,sans-serif;padding:32px 16px}}
.intro{{max-width:1180px;margin:0 auto 24px}} .intro h1{{font-size:28px}} .intro p{{color:#555;margin-top:6px}}
.style{{max-width:1180px;margin:0 auto 28px;background:#fff;border-radius:20px;padding:20px}}
.style header{{display:flex;gap:18px;align-items:flex-start;margin-bottom:14px;flex-wrap:wrap}}
.style header>div:first-child{{flex:1;min-width:240px}}
.style h2{{font-size:20px}} .style p{{color:#555;font-size:14px;margin-top:4px}} .meta{{font-size:12px!important}}
.note{{color:#8a4a26!important;font-size:12px!important}}
.sw{{display:flex;gap:4px}} .sw i{{width:22px;height:22px;border-radius:50%;display:block;border:1px solid #0001}}
.pick{{font:600 13px -apple-system,system-ui;border:0;border-radius:99px;padding:8px 16px;background:#1d1d1f;color:#fff;cursor:pointer}}
.pair{{display:grid;grid-template-columns:repeat(auto-fit,minmax(360px,1fr));gap:12px}}
.pv{{display:flex;background:var(--canvas);border-radius:14px;overflow:hidden;min-height:420px;font-family:var(--font);color:var(--text)}}
.pv .side{{width:124px;background:var(--sidebar);padding:12px 8px;flex:none}}
.pv .nav{{display:flex;align-items:center;gap:6px;padding:6px 8px;border-radius:9px;font-size:12px;font-weight:500}}
.pv .nav .g{{color:var(--accent);font-weight:700;width:14px;text-align:center}} .pv .nav.sel{{background:var(--brand-tint)}} .pv .nav .sm{{margin-left:auto;padding:1px 7px;font-size:10px}}
.pv .body{{flex:1;padding:16px;min-width:0;overflow:hidden}}
.pv .hi{{font:700 22px var(--font-head)}}
.pv .grid{{display:grid;grid-template-columns:1.5fr 1fr 1fr;gap:10px;margin:12px 0}}
.pv .hero{{padding:16px}} .pv .hero .h{{font:700 16px var(--font-head);margin-top:10px}} .pv .sm2{{font-size:12px;opacity:.85}}
.pv .card{{padding:14px}} .pv .stat{{display:flex;flex-direction:column;gap:8px}} .pv .circle{{width:32px;height:32px;font-size:16px}} .pv .num{{font-size:22px}}
.pv .list{{padding:4px 14px}} .pv .row{{padding:8px 0;gap:10px}} .pv .sq{{width:34px;height:34px;flex:none}} .pv .bar{{margin-top:6px}}
.pv .chip{{font-size:11px;padding:4px 9px}} .pv .btn{{height:28px;font-size:12px}}
.toast{{position:fixed;bottom:20px;left:50%;transform:translateX(-50%);background:#1d1d1f;color:#fff;padding:10px 16px;border-radius:99px;font-size:13px;opacity:0;transition:opacity .2s}}
@media (max-width:720px){{.pv .grid{{grid-template-columns:1fr 1fr}} .pv .hero{{grid-column:1/-1}} .pv .side{{display:none}}}}
</style></head><body>
<div class="intro"><h1>Pick a style</h1><p>Each style shows the same screen in light and dark. They share one structure: canvas and cards, one hero card, pastel role chips (done, running, review, failed) and one primary button. Pick one, or describe your own and it gets built from your brand color.</p></div>
{''.join(cards)}
<div class="toast" id="toast"></div>
<script>
function pick(id,btn){{
  try{{navigator.clipboard.writeText(id)}}catch(e){{}}
  const t=document.getElementById('toast');t.textContent='Copied "'+id+'". Tell Claude this id.';t.style.opacity=1;setTimeout(()=>t.style.opacity=0,2400);
}}
</script></body></html>"""
    write(out, page)


def starter(ref, out, platform="macos", title="Screen"):
    s = load_style(ref)
    if platform == "ios":
        frame = """.frame{width:393px;height:852px;margin:24px auto;border-radius:48px;overflow:hidden;background:var(--canvas);box-shadow:0 30px 80px rgba(0,0,0,.3);display:flex;flex-direction:column}
.status{height:54px;flex:none}.content{flex:1;overflow:hidden;padding:8px 16px 16px}.tabbar{height:83px;flex:none;border-top:1px solid var(--line);background:var(--sidebar)}"""
        body = '<div class="frame"><div class="status"></div><div class="content">\n  <!-- screen -->\n</div><div class="tabbar"></div></div>'
    else:
        frame = """.window{width:1280px;height:800px;margin:24px auto;border-radius:14px;overflow:hidden;display:flex;background:var(--canvas);box-shadow:0 30px 80px rgba(0,0,0,.35)}
.sidebar{width:240px;background:var(--sidebar);padding:14px 12px;flex:none;border-right:1px solid var(--line)}
.main{flex:1;display:flex;flex-direction:column;min-width:0}.toolbar{height:52px;display:flex;align-items:center;gap:12px;padding:0 24px;border-bottom:1px solid var(--line);flex:none}
.content{flex:1;overflow:hidden;padding:26px 36px}"""
        body = '<div class="window"><aside class="sidebar"></aside><div class="main"><div class="toolbar"><h1 class="t1" style="margin-right:auto">' + html.escape(title) + '</h1></div><div class="content">\n  <!-- screen -->\n</div></div></div>'
    page = f"""<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{html.escape(title)}</title>{ICONS}
<style>
/* Style: {s['name']} ({s['id']}). Tokens come from the style; don't add literal colors, radii or font sizes outside the scale. */
{css(s)}
{COMPONENTS}
body{{background:#D9D9DE;padding:16px}}
{frame}
.toggle{{position:fixed;top:12px;right:12px;font:600 12px -apple-system,system-ui;border:0;border-radius:99px;padding:8px 14px;background:#1d1d1f;color:#fff;cursor:pointer}}
</style></head><body>
<button class="toggle" onclick="document.documentElement.dataset.theme=document.documentElement.dataset.theme==='dark'?'light':'dark'">Light / Dark</button>
{body}
</body></html>"""
    write(out, page)


if __name__ == "__main__":
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    if a[0] == "gallery":
        gallery(a[1], a[2] if len(a) > 2 else STYLES)
    elif a[0] == "export":
        print(json.dumps(load_style(a[1]), indent=2))
    elif a[0] == "css":
        print(css(load_style(a[1])))
    elif a[0] == "starter":
        opts = dict(zip(a[3::2], a[4::2]))
        starter(a[1], a[2], opts.get("--platform", "macos"), opts.get("--title", "Screen"))
    else:
        sys.exit(__doc__)
