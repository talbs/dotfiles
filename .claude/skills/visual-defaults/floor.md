# The Floor — five engineering contracts

Work top to bottom; each depends on the one above. The failure these prevent is **unexpressible hierarchy**: once four roles share one grey, no grey is left to say "quieter than that one."

## 1. The first CSS written is `:root`

The token layer exists before any component rule. **Tokens are named by role, never by value or size** — `--type-sm` can hold five jobs; `--type-label` can hold one. Two roles sharing a value is fine: two aliases, one value.

| Group | Minimum roles | The rank it protects |
|---|---|---|
| Text color | primary, secondary, tertiary | Secondary text has its own internal hierarchy |
| Border color | container, control, divider | Control edge holds ≥3:1 on every surface it sits on; only the divider rank may sit below |
| Type size | 5, each paired with a line-height; no 1px neighbors — adjacent steps differ by ~12%+ | Two roles one pixel apart are one role |
| Weight | 400, 500, 600 | 500 is the middle rank labels and interactive text need |
| Spacing | 5, named by relationship (§3) | Nesting depth is visible in the numbers |
| Elevation | 2–3 shadows | Gives §2 somewhere to go before it reaches a border |
| Radius | container, control, pill | Nested radius derives from the parent |

Component rules reference tokens. A literal value inside a component rule is a token whose role hasn't been named yet — name it, add it above.

## 2. Separation walks a ladder

**The ladder separates compositional units** — sections, cards, groups, fields. Repeated data rows are not compositional units; they get their own rule below.

Two things need separating. Work down. Stop at the first rung that works.

1. **Whitespace**
2. **Background change**
3. **Elevation** — shadow
4. **Border**

A border in the output means the three above were tried and rejected. A divider inside a bordered container means the ladder was skipped — hoist the separation up a rung.

**Repeated rows of data** (tables, dense lists — anything scanned, row after row): a hairline divider is the *first* tool, not the last. Whitespace-per-row kills density; zebra striping hurts scanning. The divider takes the divider token and stays under the structural floor — the row rhythm, not the line, carries the separation.

**On a dark surface, elevation is lightness.** Shadows barely read on dark; closer = lighter, and card-vs-page steps run ~1.2–1.4:1 — under the structural floor by design. So dark surfaces take the border fallback by default: small lightness step for depth, a real border for the boundary. The shadow rung is skipped, not failed.

**The rung guard: a separation that disappears in greyscale isn't a separation.** Whatever rung you stop on, the two sides differ in lightness (3:1 for anything structural) or the element picks up a border fallback and a `forced-colors` rule. A tint that only shifts hue is decoration, not structure.

## 3. Spacing states a relationship

Gap size is a claim about how related two things are. The scale is named by relationship:

`tight` → `related` → `group` → `section` → `page`

Two properties of the finished output:

- a container's padding and the gap between its children come from different tokens — equal values assert that nesting doesn't exist
- a pair's internal gap sits one rung below the gap to its neighbors; a heading sits closer to its own group than that group sits to the next

Pick the token from the relationship, then round to the scale — not the reverse.

## 4. The state list precedes the default rule

For every interactive element, write the list before the first rule:

`default` · `hover` · `focus-visible` · `active` · `disabled` · `loading`

For every data surface: `empty` · `loading` · `error` · `partial`.

Three properties of the finished output:

- every state on the list has a rule — and a state with no scenario that triggers it is deleted, not styled
- every state carries a signal that is not color: border, weight, icon, position, or copy
- every interactive element declares its target size — `min-height: 44px` where touch is expected, 36px at pointer-dense minimum. Target size is an input to the component, never the output of padding + line-height
- **every state rule has been rendered and looked at, on every variant it applies to** — a spinner is checked on each button variant it can appear on. A state written but never seen is selector coverage, not design.

An empty state carries an action. **A destructive action that is not the page's primary job gets secondary or tertiary treatment** — the big red fill belongs on the confirmation step, where destruction *is* the primary action. Focus rings built from `box-shadow` vanish in forced-colors — pair them with a transparent outline.

*This section gets skipped because a state tends to get built only when it has copy to write. Hover has no copy.*

## 5. Color is ranks, then pairs

You need more colors than you think — as **ranks within a few hues**, not more choices:

- **Three text greys**, and greys may lean warm or cool toward the brand hue — grey doesn't have to be grey.
- **Three border greys** (§1) — a control edge and a content divider are different ranks, not one value.
- **Brand and semantic are different jobs.** Success green and accent green are different colors, or every green element reads as a status. Each semantic hue gets its own small ramp: text, strong, soft surface.
- A soft surface still obeys the rung guard — a danger tint at the page's lightness marks nothing.

Build ramps in `oklch()` so the middle of a ramp keeps its saturation instead of going muddy.

Then the check: **a color is approved as a pair** — `(foreground, background, ratio)`, never alone.

| Pair | Floor |
|---|---|
| Body text | 4.5:1 |
| Large text — 24px, or 18.66px at 600+ | 3:1 |
| UI boundary, icon, or structural tint | 3:1 |

Compute the ratio — estimating is how a palette ships broken. Borders are pairs. Composed states are pairs on every variant they sit on. The property that makes a hairline border look tasteful on white is the same property that puts it at 1.36:1.

## Before calling it done

`audit.py <file>` covers the mechanical half — run it and read every flag before acting (a border-drawn icon glyph taking a text color is a legitimate exception). `audit.py ratio <fg> <bg>` computes any pair. What the script cannot see, check by hand:

- [ ] a ratio computed for every pair the page actually composes — including states on each variant they sit on
- [ ] the page still has structure in greyscale
- [ ] tabbing through shows a ring on every control
- [ ] at least one separation on the page works without a border
- [ ] every state rule was rendered and seen; zero speculative states remain
- [ ] the layout was checked at 375px
