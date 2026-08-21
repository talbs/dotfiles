# Skill-improvement loop — reusable infrastructure

How this skill was built and how to extend it to a new surface (marketing, overlays, etc.).
Method: RED (cold build, torn down) → GREEN (build with skill, re-review) → REFACTOR (edit only against observed failures; retro-audit candidates against corpus/ before entry).

## Builder prompt skeleton
Single standalone HTML file, embedded CSS, no frameworks/libraries. Fix the CONTENT exactly (sections, values, states — include one error state, one empty state, one destructive action) so only the design varies between runs. For skill-on runs: "FIRST invoke the visual-defaults skill and follow it." Always ask: "reply with the path plus a one-line note on any place where the skill's guidance felt wrong or inapplicable" — builder friction reports found the density and dark-mode inversions before any reviewer did.

## Reviewer contracts (run as parallel cold agents; never show them your own self-review)
1. **Design critique** — lenses: hierarchy (count roles per size/color value), spacing (equal gaps for unequal relationships), typography, color, depth, states, responsive <600px. Output: `file:line — [severity] problem + fix`, then ROOT CAUSES phrased as the reflex to unlearn (most valuable output), then what they'd deliberately NOT flag.
2. **A11y/semantics** — heading outline, landmarks, programmatic association (label/for, aria-describedby, aria-invalid), keyboard + focus visibility, computed contrast ratios (make them show the math), color-alone state signals, touch targets. Plus: "the 3 findings a visual designer would miss."
3. **Scoped verifier** (GREEN rounds) — checks ONLY the contracts just edited; demands computed evidence, live-browser tab-through, greyscale screenshots.

## RED evidence digest — baseline settings page

(The sibling skill's charter and boundary live in ~/.claude/skills/structural-defaults/CHARTER.md; this digest is its RED evidence.)
Six root-cause reflexes found (A–E are visual-defaults; F is the sibling's charter):
- A: reuses the value already in the file instead of naming the role (one grey/border/size doing 8+ jobs)
- B: separation is always a 1px border; space/background/elevation never considered
- C: spacing picked for tidiness not relationship; equal gaps assert equal relationships
- D: only states with copy to write get designed; hover/focus/disabled don't exist
- E: color approved alone, never as (fg, bg, ratio) — every non-default color failed AA
- F (STRUCTURAL, uncovered): visual proximity treated as association (no label/for, no aria-describedby anywhere); div-first markup upgraded to real elements only when styling demands it; one heading in the whole document, no landmarks, no <form>; state encoded in color+class with no ARIA counterpart; DOM order vs visual order divergence (column-reverse inverting tab order); autocomplete (WCAG 1.3.5 AA) universally missing.
Key baseline numbers: #888 on white 3.54:1, primary btn 3.68:1, error 3.76:1, badge 3.00:1, input border 1.36:1 — "not a set of mistakes, a palette that was never checked."

## Lessons about wording (hard-won)
- Structural/checkable contracts bind; prose judgment clauses lose to convenience at the use site (trap 3 failed twice as prose → became an audit.py check).
- Additive recipes ("write this extra rule") bind better than in-flow constraints.
- Conditionals keyed to observable predicates (dense rows, dark surface) — never exemption clauses on an existing rule.
- Rules enter only with observed failures: killed labels-last-resort, two-part shadows, em-units, grey-on-colored as unearned.
