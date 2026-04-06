# UI/UX Standard — Netflix/Apple Benchmark

Every user-facing surface meets this standard. Enforced by the UI Designer
(Phase 1) before build and the Accessibility Engineer (Phase 3) before ship.

## The 7 principles

### 01 — Nothing is outdated
Every component feels contemporary and intentional. If it looks like it was
built two years ago, it gets redesigned. No rounded-corner-less boxes, no
unstyled selects, no default browser form elements.

### 02 — Motion is communication
Animations convey state changes, not decoration. Every transition has:
- Purpose: what state change does this communicate?
- Duration: 150ms for micro-interactions, 200-300ms for page transitions
- Easing: ease-out for entrances, ease-in for exits, ease-in-out for transforms
- If you cannot explain the animation in one sentence, it does not ship.

### 03 — Perfection in the details
Spacing follows the 8px grid (4, 8, 12, 16, 24, 32, 48, 64). Typography uses
a defined scale. Alignment is exact. 4px off is wrong. Users feel quality as
a gestalt — they may not notice details, but they notice their absence.

### 04 — Zero clutter
If it doesn't serve the user right now, it doesn't exist on screen. White
space is a design element. Density is earned through progressive disclosure —
show the simple view first, reveal complexity on demand.

### 05 — System consistency
Every surface follows the design system. No one-offs. No local overrides.
When a component needs to change, the design system is updated — not bypassed.
Design tokens are the source of truth for colors, spacing, typography, shadows.

### 06 — Performance as UX
60fps animations. Sub-100ms interactions. No cumulative layout shift. No flash
of unstyled content. Slow is broken — users experience performance as quality.

### 07 — Accessibility is designed in
WCAG 2.1 AA is the floor, not the ceiling. Built in Phase 1, validated in Phase 3.

## Enforceable rules

### Every interactive element has 4 states
- **Default** — resting appearance
- **Hover** — cursor over (desktop), slightly elevated or highlighted
- **Focus** — keyboard navigation, visible focus ring (2px solid, offset 2px)
- **Disabled** — reduced opacity (0.5), cursor-not-allowed, non-interactive

### Every data view has 3 states
- **Loading** — skeleton placeholder matching the layout shape, `animate-pulse`
- **Empty** — friendly message + clear CTA ("No proposals yet. Create your first →")
- **Error** — error message + retry action, never a blank screen or console error

### Touch targets
Minimum 44×44px on mobile. Interactive elements with smaller visual size use
padding to reach the touch target. No exception.

### Color contrast
- Normal text (<18px): 4.5:1 ratio minimum
- Large text (≥18px bold or ≥24px): 3:1 ratio minimum
- Interactive elements: 3:1 against adjacent colors
- Color is never the sole indicator of state — always paired with text, icon, or pattern

### Typography scale
Use a defined, limited set of text styles. No arbitrary font sizes.
```
Display:  text-3xl  font-bold      (hero headings)
H1:       text-2xl  font-bold      (page titles)
H2:       text-xl   font-semibold  (section titles)
H3:       text-lg   font-medium    (subsection titles)
Body:     text-base leading-relaxed (main content)
Caption:  text-sm   text-muted     (metadata, labels)
Tiny:     text-xs   text-dim       (badges, counters)
```

### Spacing
8px base grid enforced via Tailwind spacing scale:
```
gap-1 = 4px    (tight grouping)
gap-2 = 8px    (related elements)
gap-3 = 12px   (form fields)
gap-4 = 16px   (section padding)
gap-6 = 24px   (between sections)
gap-8 = 32px   (major sections)
```

### Responsive breakpoints
- Mobile first. Default styles target mobile.
- `sm:` (640px) — large phones landscape
- `md:` (768px) — tablets
- `lg:` (1024px) — desktop
- `xl:` (1280px) — wide desktop
- Sidebar collapses below `lg:`. Tables become cards below `md:`.
