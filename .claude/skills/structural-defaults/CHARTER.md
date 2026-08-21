# structural-defaults — charter (skill not yet built)

No SKILL.md on purpose: an unbuilt skill must not register. Build it with the loop in visual-defaults/loop-notes.md.

**Territory:** accessibility and correctness that live in MARKUP — programmatic association (label/for, aria-describedby, aria-invalid), landmarks and heading outline, real elements over styled divs, DOM order vs visual order (column-reverse tab-order inversions), form semantics (name, autocomplete — WCAG 1.3.5), state declared in ARIA not just class names, role="switch" vs checkbox.

**Boundary with visual-defaults (agreed, evidence-derived):** a11y that lives in CSS stays in floor.md — focus-visible rules, forced-colors fallbacks, contrast, computed target sizes. A11y that lives in markup is this skill's. Edge cases both must name at build time: the focus ring (CSS) vs what's focusable (markup); target size (CSS) vs hit semantics (markup); error styling (CSS) vs aria-invalid + describedby wiring (markup).

**RED baseline, already banked:** the reflex-F digest in visual-defaults/loop-notes.md — visual proximity treated as association, div-first markup, one heading per document, color+class state with no ARIA counterpart. Both settings-page review transcripts' findings are summarized there; corpus/baseline.html reproduces most defects live.
