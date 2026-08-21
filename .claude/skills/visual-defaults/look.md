# The Look — visual judgment layer

Run against the **rendered page**, not the code. The floor must already pass — judgment needs ranks to work with.

## The squint protocol

Screenshot the page. Half-close your eyes, or blur it mentally. Then, in order:

**1. Where does the eye land first — and is that the most important thing?**
If not, don't amplify the important thing. Quiet its competitors instead: softer color, lighter weight, remove a background, shrink it. Emphasis is relative; the cheapest way to turn something up is to turn everything else down.

**2. What has a background, border, or color it doesn't need?**
A sidebar with a background competes with the content. A panel that could sit directly on the page usually should. Every box asks for attention — make each one prove it.

**3. Is data wearing `label: value` badges?**
Format and context often carry meaning alone — an email looks like an email, a price looks like a price. Fold labels into values: "12 left in stock," "3 bedrooms." Where a label must exist, it's supporting cast — smaller, lighter, caps — and the data is the star. *Flip this on scan-for-label surfaces* (spec sheets, dense reference tables): there, users hunt the label, so the label leads.

**4. Are section titles bigger than they deserve?**
Most titles act as labels, not headlines — the content is the focus. Titles small, quiet, sometimes visually hidden entirely. The element (`h2`) is a semantic choice; its size is a separate one.

**5. Anything heavy that shouldn't be? Anything subtle that vanished?**
Weight and contrast are exchangeable currencies. A solid icon next to text is louder than the text — soften its color. A 1px border too faint to see — thicken to 2px and *lighten* it, rather than darkening (dark hairlines go harsh). Balance by trading one currency for the other.

**6. Does it feel designed, or assembled?**
Correct-but-generic is the floor's ceiling. If everything passes and the page is still bland, reach into the moves palette.

## The moves palette

Not rules — options. Reach for **one** when the squint says "assembled." Restraint is part of the move.

| Move | Reach for it when |
|---|---|
| **Supercharge a default** — icons replace list bullets (content-specific beats generic checkmarks); oversized tinted quote marks on a testimonial; a thick tinted underline that overlaps link text; brand color on checked checkbox/radio states | A stock element sits at the center of attention looking like the browser made it |
| **Accent border** — a flat band of brand color: top of a card, left edge of an alert, short underline beneath a headline, top of the whole layout | The design is clean but bloodless; you want color without illustration ("a colored rectangle takes no graphic-design talent") |
| **Background shift** — tint one panel to crown it (a pricing tier); alternate section bands to break a long page's monotony; a soft two-hue gradient (hues ≲30° apart); a low-contrast repeating pattern, full-bleed or along one edge; one geometric shape anchored off a corner | Sections blur together, or one item in a row deserves the crown |
| **Empty state as a first impression** — illustration or icon, one-line pitch, emphasized CTA; hide the supporting chrome (tabs, filters, search) until content exists to support | The zero-data view is a grey sentence in a void — it's the user's first screen, not an error |
| **Promote a quote** — testimonial quote marks become large, tinted, visual | Social proof reads as a paragraph instead of a feature |

## The squint report

The protocol's output is six written lines — one per question, in the transcript, every time. Each line is either the change made or `intentional: <the reason>`. A question with no line was skipped, not passed. Findings here are questions, not defects — but "intentional" is only a valid answer when it is stated.

## Order of operations

Floor first (correct), squint second (focused), moves last (designed) — and only one move per bland spot. Two moves in the same viewport compete; the palette is seasoning, not sauce.
