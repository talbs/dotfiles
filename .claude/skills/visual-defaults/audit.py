#!/usr/bin/env python3
"""Mechanical checks for the visual-defaults skill.

Usage:
  audit.py <file.html|file.css>     run all checks
  audit.py ratio <color> <color>    WCAG contrast ratio (hex or oklch())
"""
import re, sys, math

def srgb_to_lin(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def hex_to_rgb(h):
    h = h.lstrip('#')
    if len(h) == 3:
        h = ''.join(ch * 2 for ch in h)
    return tuple(int(h[i:i+2], 16) / 255 for i in (0, 2, 4))

def oklch_to_rgb(l, c, h):
    hr = math.radians(h)
    a, b = c * math.cos(hr), c * math.sin(hr)
    l_ = (l + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m_ = (l - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s_ = (l - 0.0894841775 * a - 1.2914855480 * b) ** 3
    r = +4.0767416621 * l_ - 3.3077115913 * m_ + 0.2309699292 * s_
    g = -1.2684380046 * l_ + 2.6097574011 * m_ - 0.3413193965 * s_
    bl = -0.0041960863 * l_ - 0.7034186147 * m_ + 1.7076147010 * s_
    def gam(x):
        x = max(0.0, min(1.0, x))
        return 12.92 * x if x <= 0.0031308 else 1.055 * x ** (1 / 2.4) - 0.055
    return gam(r), gam(g), gam(bl)

def parse_color(s):
    s = s.strip()
    if s.startswith('#'):
        return hex_to_rgb(s)
    m = re.match(r'oklch\(\s*([\d.]+)%?\s+([\d.]+)\s+([\d.]+)', s)
    if m:
        l = float(m.group(1))
        if '%' in s.split(m.group(1))[1][:1] or l > 1:
            l /= 100
        return oklch_to_rgb(l, float(m.group(2)), float(m.group(3)))
    return None

def luminance(rgb):
    r, g, b = (srgb_to_lin(v) for v in rgb)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def ratio(c1, c2):
    l1, l2 = luminance(parse_color(c1)), luminance(parse_color(c2))
    hi, lo = max(l1, l2), min(l1, l2)
    return (hi + 0.05) / (lo + 0.05)

FAMILY = {  # property prefix -> token substrings that belong to it
    'border': ('border',),
    'background': ('surface', 'bg', 'fill', 'brand', 'accent', 'soft', 'track',
                   'danger', 'success', 'warning', 'page', 'card', 'sunken',
                   'subtle', 'inset', 'hover', 'pressed', 'strong', 'focus'),
    'color': ('text', 'brand', 'accent', 'danger', 'success', 'warning',
              'inverse', 'link', 'focus', 'strong'),
    'outline': ('focus', 'border', 'accent', 'brand', 'danger'),
}
MISMATCH = {  # property prefix -> token substrings that signal a borrowed family
    'border': ('text',),
    'background': ('text', 'border', 'divider'),
    'color': ('border', 'divider', 'surface', 'bg'),
}

def extract_css(path):
    src = open(path, encoding='utf-8').read()
    if path.endswith('.html'):
        m = re.search(r'<style[^>]*>(.*?)</style>', src, re.S)
        offset = src[:m.start(1)].count('\n') if m else 0
        return (m.group(1) if m else ''), offset
    return src, 0

def audit(path):
    css, offset = extract_css(path)
    lines = css.split('\n')
    findings = []
    root_m = re.search(r':root\s*{(.*?)}', css, re.S)
    root = root_m.group(1) if root_m else ''
    root_end = css.index(root_m.group(0)) + len(root_m.group(0)) if root_m else 0

    # 1. size/value-named tokens
    for m in re.finditer(r'(--[\w-]+)\s*:', root):
        name = m.group(1)
        if re.search(r'-(xs|sm|md|lg|xl|\d+)$', name):
            findings.append(f"TOKEN NAMED BY SIZE/VALUE: {name}")

    # 2. color literals outside :root
    body = css[root_end:]
    for i, line in enumerate(body.split('\n')):
        if re.search(r':\s*[^;]*(#[0-9a-fA-F]{3,8}\b|oklch\(|rgb\()', line) and '--' not in line.split(':')[0]:
            findings.append(f"LITERAL OUTSIDE :root: {line.strip()[:70]}")

    # 3. trap 3 — property/token family mismatch
    for prop, bad in MISMATCH.items():
        for m in re.finditer(rf'(?<![\w-])({prop}[\w-]*)\s*:\s*[^;]*var\((--[\w-]+)\)', css):
            pname, token = m.group(1), m.group(2)
            if pname.startswith('border-radius'):
                continue
            if any(b in token for b in bad) and not any(g in token for g in FAMILY.get(prop, ())):
                ln = css[:m.start()].count('\n') + 1 + offset
                findings.append(f"FAMILY MISMATCH line {ln}: {pname}: var({token})")

    # 4. presence checks
    for needle, label in [(':focus-visible', 'NO :focus-visible RULE'),
                          ('forced-colors', 'NO forced-colors BLOCK'),
                          ('line-height', 'NO line-height DECLARED')]:
        if needle not in css:
            findings.append(label)

    # 5a. type-scale steps: adjacent size tokens must differ ~12%+
    sizes = []
    for m in re.finditer(r'(--[\w-]*(?:type|font-size)[\w-]*)\s*:\s*([\d.]+)(rem|px)', root):
        if 'line' in m.group(1) or 'leading' in m.group(1):
            continue
        px = float(m.group(2)) * (16 if m.group(3) == 'rem' else 1)
        sizes.append((px, m.group(1)))
    sizes.sort()
    for (a, an), (b, bn) in zip(sizes, sizes[1:]):
        if a > 0 and b / a < 1.10:
            findings.append(f"TYPE STEPS TOO CLOSE: {an} ({a:g}px) vs {bn} ({b:g}px)")

    # 5b. a container's padding and its children's gap from one token
    for m in re.finditer(r'\{([^}]*)\}', css):
        block = m.group(1)
        pads = set(re.findall(r'padding[^;:]*:\s*[^;]*var\((--[\w-]+)\)', block))
        gaps = set(re.findall(r'\bgap\s*:\s*[^;]*var\((--[\w-]+)\)', block))
        for t in pads & gaps:
            ln = css[:m.start()].count('\n') + 1 + offset
            findings.append(f"PADDING AND GAP SHARE TOKEN line {ln}: var({t})")

    # 5c. target size never declared at all
    if 'min-height' not in css:
        findings.append("NO min-height ANYWHERE — target sizes are falling out of type metrics")

    # 5. one-grey check: count distinct text-color tokens
    greys = set(re.findall(r'--[\w-]*text[\w-]*(?=\s*:)', root))
    if len(greys) < 3:
        findings.append(f"ONLY {len(greys)} TEXT-COLOR TOKENS (floor is 3): {sorted(greys)}")

    return findings

if __name__ == '__main__':
    if len(sys.argv) == 2 and sys.argv[1] == 'test':
        import os
        base = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'corpus')
        checks = [
            ('baseline.html', 'catches the RED artifact broadly',
             lambda f: any('NO :focus-visible' in x for x in f) and any('LITERAL' in x for x in f) and len(f) >= 15),
            ('green4.html', 'catches trap-3 cross-family borrows',
             lambda f: sum('FAMILY MISMATCH' in x for x in f) >= 2),
            ('dark.html', 'stays quiet on family mismatches in a clean dark build',
             lambda f: sum('FAMILY MISMATCH' in x for x in f) == 0),
            ('dash.html', 'accepts min-height-declaring dense build',
             lambda f: not any('NO min-height' in x for x in f)),
        ]
        ok = True
        for name, why, pred in checks:
            f = audit(os.path.join(base, name))
            good = pred(f)
            print(('PASS ' if good else 'FAIL ') + f"{name} — {why} ({len(f)} findings)")
            ok = ok and good
        sys.exit(0 if ok else 1)
    if len(sys.argv) == 4 and sys.argv[1] == 'ratio':
        print(f"{ratio(sys.argv[2], sys.argv[3]):.2f}:1")
    elif len(sys.argv) == 2:
        f = audit(sys.argv[1])
        for line in f:
            print(f"  FAIL {line}")
        print(f"{sys.argv[1].split('/')[-2] if '/' in sys.argv[1] else sys.argv[1]}: {len(f)} findings")
    else:
        print(__doc__)
