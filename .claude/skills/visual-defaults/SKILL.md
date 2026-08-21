---
name: visual-defaults
description: Use when writing or reviewing CSS for a user-facing interface — at the point of writing the first style rule, and again before calling a UI change done. Applies to any stack and assumes no component library.
---

# Visual Defaults

Two layers, in order. Do not work from this file's summary of either — this file has none; the layers live in their files.

**Layer 1.** Read [floor.md](floor.md) before writing the first style rule. Run `audit.py` before calling the floor done.

**Layer 2.** Read [look.md](look.md) after the page renders, before calling the change done. When a dev server exists, this layer runs inside the once-over skill's pass — do not run it twice.

Floor findings are defects — fix them. Look findings are questions — answered in writing, per look.md's report shape.
