---
name: wa-utility-first
description: Use when reviewing, cleaning up, or reducing custom CSS in a Web Awesome project — "see if you can use WA utilities/classes instead of custom CSS", "clean up this stylesheet" — or before writing a custom rule that might duplicate a WA utility. Applies to webawesome-app, webawesome-pro, webawesome chrome, and any repo with @awesome.me/webawesome vendored.
---

# Swapping Custom CSS for Web Awesome Utilities

## Overview

The WA utility set is small and **closed**. Bad reviews come from trusting memory or in-file comments instead of the shipped CSS. Core principle: **the vendored utility source is the only authority — read it before proposing or rejecting a swap.**

## Before proposing anything

1. **Find the vendored source.** Glob for the webawesome package's `styles/utilities/*.css` (src or dist). The aggregate `utilities.css` lists everything that ships. Note: `wa-mobile-only` / `wa-desktop-only` live in `layers.css`, not `utilities/`. The pro package ships themes and palettes only — no extra utility classes.
2. **Treat in-file comments about WA capability as claims to verify.** Comments go stale; utilities have shipped answers to problems comments call impossible. (A comment said "`.wa-visually-hidden` can't cross into the shadow root" — but `wa-visually-hidden-label` targets `::part(label)` from outside for exactly that case.)
3. **Grep before claiming usage.** Before saying where a class is applied or where a utility class would go, grep the templates _and_ JS (classes get added by scripts, and rows get cloned). A selector matched by nothing is a deletion, not a substitution.

## Inventory (a map — confirm against source, versions drift)

- **Layout composables**: `wa-stack`, `wa-cluster`, `wa-flank(:start/:end)`, `wa-split(:column/:row)`, `wa-grid` + `wa-span-grid`, `wa-frame(:square/:landscape/:portrait)`
- **Flex knobs**: `wa-gap-{0,3xs..5xl}`, `wa-align-items-*`, `wa-align-self-*`, `wa-justify-content-*`, `wa-flex-wrap`, `wa-flex-nowrap`, `wa-flex-wrap-reverse`
- **Text**: `wa-body/heading/caption/longform-{3xs..5xl}` (family + weight + line-height; heading adds balance; caption adds quiet color), `wa-font-size-{3xs..5xl}`, `wa-font-weight-{light,normal,semibold,bold}`, `wa-color-text-{normal,quiet,link}`, `wa-text-truncate`, `wa-text-{nowrap,balance,pretty}`, `wa-text-{uppercase,lowercase,capitalize}`, `wa-text-{start,center,end,justify}`
- **Links/lists**: `wa-link`, `wa-link-plain` (both add a hover color-mix), `wa-list-plain` (also zeroes list padding and li margins)
- **A11y**: `wa-visually-hidden`, `wa-visually-hidden-force`, `wa-visually-hidden-label` / `-hint` (these two pierce `::part(label|form-control-label|hint)`; all use `!important`)
- **Misc**: `wa-border-radius-{s,m,l,pill,circle,square}`, `wa-size-{xs..xl}`, variant remaps `wa-{brand,neutral,success,warning,danger,invert}` (token remap only — they recolor nothing by themselves), `wa-prose`, `wa-placeholder`, `wa-cloak`, `wa-mobile-only` / `wa-desktop-only` (only work inside a `wa-page[view]`)

**Does not exist — never invent**: padding/margin utilities, display utilities, width/measure utilities, strike/line-through, shadow/elevation classes.

## Mechanics that break naive swaps

- **Composables carry defaults**: every composable gets `gap: m`; cluster/flank/split default `flex-wrap: wrap`; cluster + flank center-align; split space-between; all zero direct-child margins. A swap must account for _every_ default, not just the declaration being replaced. Defaults sit in `:where()` (zero specificity), so a real class like `wa-flex-nowrap` overrides them.
- **`wa-flank` growth model**: the flank child gets `flex-basis: var(--flank-size, auto); flex-grow: 1`; the content child gets `flex-grow: 999; min-inline-size: var(--content-percentage, 50%)`. It is not `flex: none` on the icon — say what the source says.
- **Utility classes can't cross `::part()`** — except the visually-hidden `-label`/`-hint` variants, which are authored against parts.
- **Layer order**: app layers are declared after `wa-utilities`, so a surviving app rule on the same property beats an added class. A swap means _delete the rule and add the class_, never both.
- **`--flank-size`, `--content-percentage`, `--min-column-size`, `--spacing`** on utility-classed elements are the utilities' customization API. That's already idiomatic WA — leave it alone.

## Output contract

Go rule by rule through the stylesheet. Produce:

1. **Substitutions** — for each: current CSS (file:line), replacement class(es), the grep-verified markup or JS location the class goes, and every behavior difference the swap introduces (added hover states, extra resets, wrap defaults, `!important`). Write "no behavior difference" only after comparing every declaration the utility carries.
2. **Considered but kept** — each with a one-line reason.

## Common mistakes

| Mistake                                                     | Fix                                                               |
| ----------------------------------------------------------- | ----------------------------------------------------------------- |
| Trusting a comment that says WA can't do something          | Read the utility source; comments go stale                        |
| Calling a composable "the same as" a flex rule              | Compare all its defaults (wrap, gap, alignment), not one property |
| Claiming where a class is or would be used without grepping | Grep templates and JS first                                       |
| Inventing `wa-padding-*`, `wa-hidden`, `wa-w-*`             | The set is closed — see the absence list                          |
