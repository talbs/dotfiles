# Corpus manifest — what each fixture exercises

Regression inputs for audit.py and retro-auditing candidate rules. Built 2026-08-21.

- `baseline.html` — settings page, cold build, NO skill. The RED artifact: ~30 findings, every non-default color fails AA, zero states. The "before."
- `green.html` — settings, skill v1 (contracts only). Shadow-tint structure that dies in greyscale; states written but never rendered.
- `green2.html` — settings, v2 (rung guard + rendering clause). Size-named tokens (--type-xl); token-role reuse.
- `green3.html` — settings, v3 (role naming + border floors). Border neutrals just under 3:1; trap-3 cross-family borrows.
- `green4.html` — settings, v4 (known traps added). Two live trap-3 hits (text token as hover border) + chevron-glyph legit exceptions. The standing floor-only A/B arm.
- `dark.html` — settings, dark theme, post-dark-amendment. audit.py clean; elevation-as-lightness + border fallback idiom.
- `dash.html` — dense dashboard, post-density-amendment. Hairline row dividers as first tool; min-height on controls.
- `look1.html` — settings, two-layer build (floor + look). Blind-judged "more designed" vs green4. The standing look-layer A/B arm.
