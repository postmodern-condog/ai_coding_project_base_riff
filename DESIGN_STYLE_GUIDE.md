# Design & Style Guide

Visual design and UX guidance for AI agents implementing user-facing features. Consult this document when generating UI code, choosing component styles, or writing user-facing copy.

This guide establishes defaults. Project-specific overrides in `TECHNICAL_SPEC.md` or `PRODUCT_SPEC.md` take precedence.

---

## Core Philosophy

Every design decision should reinforce **trust and clarity**. The interface should feel warm, approachable, and globally inclusive. Prioritize clarity in critical flows (pricing, errors, permissions) and add personality in positive moments (confirmations, discovery). Every screen should answer: *"Does this make the user feel safe and informed enough to proceed?"*

---

## Color

- **Palette structure:** Define a full palette with multiple tints and shades per hue (e.g. 10 variants), but use only a few at a time. Prefer warm, inviting accent colors for primary actions.
- **Backgrounds:** Default to white or light neutrals so text and imagery stand out.
- **Semantic roles:** Assign specific colors to semantic purposes (primary action, secondary action, destructive, success, warning, error) and use them consistently across all screens.
- **Accessibility:** All text/background combinations must meet WCAG AA contrast minimums.
- **Tokens:** Name color tokens clearly (e.g. `primary-500`, `neutral-100`) so developers can reuse them predictably.

---

## Typography

- **Font choice:** Use a clean, friendly sans-serif with wide character support. Prefer fonts that feel warm and approachable over sterile geometric fonts.
- **Hierarchy:** Establish distinct levels — larger/bolder for headings, medium weight for subheads, regular for body. Keep the scale consistent across all screens.
- **Readability:** Favor text labels over icon-only UI. No all-caps body text. Provide ample line height and spacing.
- **Localization:** Choose fonts that support extended character sets. Test layouts with longer translations (some languages expand text by 30%+). Allow buttons and menus to grow or wrap.

---

## Iconography

- **Style:** Use a simple, consistent icon set — uniform stroke weight, corner radius, and sizing (e.g. 24x24px grid).
- **Labels required:** Always pair icons with text labels. Never rely on icons alone to convey meaning.
- **Platform conventions:** Use native or Material system icons on mobile when appropriate so the interface feels familiar.
- **Accessibility:** All meaningful icons must have accessible labels or alt text.

---

## Layout & Spacing

- **Grid:** Adopt a consistent baseline grid (e.g. 8px) and spacing scale (4, 8, 16, 24, 32, 48px).
- **White space:** Use generous padding between sections and around cards. Ample white space focuses attention and prevents visual clutter.
- **Corner radii:** Keep consistent — use smooth, medium-round corners on cards, buttons, images, and modals.
- **Elevation:** Use subtle, soft drop shadows only to indicate layered surfaces (cards, modals). Never heavy or stacked shadows.
- **Alignment:** Align content neatly on the grid. On wider screens, center primary content. On mobile, use consistent full-width rows.

---

## Imagery

- **Photo-forward:** Let high-quality images drive the design. Use large (full-bleed or edge-to-edge) images at the top of cards and screens.
- **Minimal overlay:** The interface surrounding images should be minimal and uncluttered. Overlay only essential text (title, price) with a semi-transparent background for readability.
- **Visual hierarchy:** Combine bold imagery with generous white margins. A card should show a prominent photo above a clean panel with title and metadata in clear typography.

---

## Components

### Cards

- White background, medium corner radius, subtle shadow (very light elevation).
- Structure: large top image, text section below.
- Entire card is tappable — include hover/focus states.

### Buttons

- **Primary:** Filled in accent color, bold text, slight elevation. Used for the single most important action on screen.
- **Secondary:** Outlined or text-only. Same shape and padding as primary, with a neutral border or colored text.
- **Disabled:** Gray fill or outline with reduced label opacity.
- **Sizing:** Minimum 44x44px touch target on mobile.

### Forms & Inputs

- Clear bordered or underlined inputs with left-aligned labels (floating or above-field).
- Obvious focus indicators (border color change or shadow).
- Group related fields with consistent spacing.

### Modals & Sheets

- Follow platform conventions: bottom sheet on iOS, Material dialog on Android, centered modal on web.
- Dim background. Include a clear title, concise instructions, and two actions (primary + cancel) at the bottom.
- Corner radius and shadow should match card styling.

### Navigation

- **Mobile:** Bottom tab bar with 3-5 icon+label items. Active tab uses accent color; inactive tabs use neutral gray.
- **Web/Desktop:** Top bar or sidebar with the same semantic sections.
- Common sections should be reachable from anywhere.

### Icons & Badges

- Use badges sparingly (notifications, status indicators).
- Profile avatars should be circular.
- Chips and tags follow the same radius and styling conventions as other elements.

---

## Interaction & Motion

- **Feedback:** Provide immediate visual feedback on taps (ripple, color change, or highlight). All interactive elements need hover/focus states on desktop and touch highlights on mobile.
- **Transitions:** Use smooth animated transitions to maintain spatial context. Animate shared elements (e.g. expand a card image to full screen). Keep durations short — ~200ms for feedback, 300-500ms for page transitions — with ease-in-out curves.
- **Gestures:** Follow platform conventions — swipe to browse galleries, pull-to-refresh for lists, long-press for contextual actions.
- **Touch targets:** Minimum 44x44px on mobile for all interactive elements.

---

## Microcopy & Tone

- **Clarity first:** Every word should help or delight — nothing that confuses. In critical flows (transactions, security, errors), be straightforward and neutral.
- **Warmth in positive moments:** In confirmations, discovery, or browsing — add personality and encouragement.
- **Error messages:** Clear, calm, and constructive. Use plain language. Explain what went wrong and how to fix it. No technical jargon or blame.
- **Empty states:** Show a friendly illustration or icon, a brief encouraging note, and a clear call-to-action (e.g. "No favorites yet — start exploring!").
- **Global readability:** Keep sentences short. Avoid idioms. Prefer familiar terms. Use second person ("you") for guidance and friendly possessives ("Your trips") for labels.

---

## Onboarding

- New users should immediately feel welcome and safe.
- Collect only essential information initially. Allow browsing without login; prompt for an account at the point of commitment.
- When introducing new features, use a brief tooltip or "New" badge with an easy "Skip" or "Later" option.

---

## Accessibility

- Text must be large enough and contrast high enough to meet WCAG AA.
- Support screen readers — label images and icons meaningfully.
- Design layouts that adapt to text expansion for localization.
- Ensure icons with semantic meaning have text equivalents.
- Design as if the user could be anyone, anywhere — no features or content should assume cultural familiarity.

---

## Cross-Platform Consistency

Maintain a single design language across all platforms. The same semantic structure, visual hierarchy, and color system should apply everywhere. Adapt only the platform-specific interaction patterns:

| Aspect | Shared | Platform-Adapted |
|--------|--------|------------------|
| Color palette | Yes | — |
| Typography scale | Yes | — |
| Spacing system | Yes | — |
| Component styles | Yes | — |
| Navigation pattern | — | Bottom tabs (mobile) vs top bar (web) |
| Modal style | — | Bottom sheet (iOS) vs dialog (Android) vs centered (web) |
| Gestures | — | Platform-native conventions |
