# Frontend Assets

---

## public/css/app.css

All styles in a single file. Sections in order:

| Section | Description |
|---------|-------------|
| CSS custom properties | All colour, shadow, and border tokens |
| Reset | Box-sizing, margin/padding reset, smooth scroll |
| Navbar | Sticky top bar, brand, nav links, CTA, theme button |
| Main | Max-width container and padding |
| Buttons | `.btn`, `.btn-primary`, `.btn-ghost`, `.btn-danger` |
| Forms | Inputs, selects, textareas, labels |
| Star widget | Interactive star input and read-only display |
| Badges | Status and genre chips |
| Flash toast | Fixed bottom-right dismissible toast |
| Book cards | Grid cards with status accent and press mechanic |
| Filter chips | Scrollable chip row |
| Search/sort bar | Flex search input and sort dropdown |
| Page header | List page title and count |
| Empty state | Centred icon and message |
| Hero | Two-column editorial layout |
| Stats grid | Auto-fit stat cards |
| Recent list | Bordered rows with ink separators |
| Footer | Centred muted text |
| Dark mode | All token overrides under `[data-theme="dark"]` |
| Responsive | Breakpoints at 700px and 480px |

### Design Tokens

```css
:root {
  --primary:            #6366f1;
  --primary-dark:       #4f46e5;
  --primary-light:      #eef2ff;
  --text:               #0f172a;
  --text-muted:         #64748b;
  --bg:                 #f8fafc;
  --bg-card:            #ffffff;
  --border:             #e2e8f0;
  --brut-border:        3px solid var(--brut-ink);
  --brut-shadow:        4px 4px 0 var(--brut-ink);
  --brut-shadow-sm:     2px 2px 0 var(--brut-ink);
  --brut-shadow-hover:  2px 2px 0 var(--brut-ink);
  --brut-shadow-active: 0px 0px 0 var(--brut-ink);
  --brut-ink:           #0f172a;
}

[data-theme="dark"] {
  --brut-ink: #f1f5f9;
  /* ...all colour overrides... */
}
```

### Brutalist Morphism Press Mechanic

Every interactive element shares a 3-state shadow system:

| State | box-shadow | transform |
|-------|-----------|-----------|
| Rest | `4px 4px 0 var(--brut-ink)` | none |
| Hover | `2px 2px 0 var(--brut-ink)` | `translate(2px, 2px)` |
| Active | `0px 0px 0 var(--brut-ink)` | `translate(4px, 4px)` |

The element moves toward its shadow until it disappears on full press — a physical press-down illusion. In dark mode `--brut-ink` is near-white so shadows stay visible.

### Responsive Breakpoints

| Width | Changes |
|-------|---------|
| ≤ 700px | Hero stacks to one column; divider becomes horizontal; cards go single-column |
| ≤ 480px | Hamburger nav; stats grid goes to 2 columns |

---

## public/js/app.js

### 1. No-FOUC Theme IIFE

Runs immediately on script parse, before the DOM is ready. Reads `localStorage.theme` and sets `document.documentElement.dataset.theme` to prevent a colour flash on page load.

```javascript
(function () {
  const t = localStorage.getItem('theme');
  if (t) document.documentElement.dataset.theme = t;
})();
```

### 2. Mobile Nav Toggle

Hamburger button toggles `.nav-open` on `<nav>`. Nav links shown/hidden via CSS.

### 3. Dark Mode Toggle

- Reads current `data-theme` from `<html>`
- Flips between `light` and `dark`
- Saves to `localStorage`
- Updates the button icon (moon / sun)

### 4. Star Rating Widget

Attaches handlers to each `<i>` inside `.star-input`:

- `mouseenter` — fill stars up to hovered index
- `mouseleave` — restore to saved rating
- `click` — lock in rating, update `input[name="rating"]`

Toggling `fa-solid fa-star` vs `fa-regular fa-star` switches filled and outline states.

### 5. Flash Toast Auto-Dismiss

After 4 seconds, adds `.toast-hide` which triggers a CSS fade + slide-out transition.

---

## Dark Mode

1. JS IIFE applies the saved theme before first paint — no colour flash.
2. Toggle button flips `data-theme` and saves to `localStorage`.
3. All colours are CSS custom properties. `[data-theme="dark"]` overrides every token. One attribute change on `<html>` instantly switches the entire UI.
