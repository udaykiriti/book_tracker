# Views

All views are ERB templates in `views/` rendered via `erb :name`.

---

## layout.erb

Shared wrapper rendered around every page.

- `<head>`: charset, viewport, Font Awesome 6.6.0 CDN, `app.css`
- Sticky navbar: brutalist brand wordmark (`Book` + `Track`), nav links, dark mode toggle button
- Flash toast: reads `pop_flash`, renders a dismissible toast, auto-dismissed by JS after 4 seconds
- `<main>` with `<%= yield %>` — page content slot
- Footer: `BookTrack · Your personal reading journal`
- `app.js` at bottom of `<body>`

---

## index.erb

Home page. Three sections:

### Hero

Two-column editorial layout separated by a 3px ink divider:

- **Left column**: kicker dot-label, giant split wordmark (`Book` plain + `Track` filled primary block), subtitle with left accent border
- **Right column**: "Get started" label, two stacked full-width CTA buttons (Add a Book, My Library), privacy/open meta row
- **Top-right stamp**: primary-fill corner box with the book icon

### Stats Grid

Seven auto-fit stat cards:

- Total Books
- Completed
- In Progress
- To Read
- On Hold
- Dropped
- Avg Rating (1 decimal place, shown as "—" if no ratings)

### Recent List

Up to 6 most recently added books. Each row: status accent bar, title, author, status badge. "See all" link at top.

---

## list.erb

Library page. Three sections:

### Filter Chips

Horizontal scrollable row. "All" chip + one per status, each showing its count. Active chip is highlighted. Each links to `?status=<value>`.

### Search and Sort Bar

A `GET` form with:
- Text input for `?search=` (searches title, author, genre)
- `<select>` for `?sort=` with all six sort options
- Hidden input to preserve `?status=` on re-search
- Submit button

### Book Card Grid

Auto-fit CSS grid. Each card:
- Thick top border in the status colour
- Title
- Author (uppercase, bold)
- Genre badge (if set)
- Read-only star rating
- Notes snippet (120 chars, if set)
- Edit button → `/books/:id/edit`
- Delete button → `POST /books/:id/delete`

Empty state shown if no books match the current filters.

---

## new.erb

Add-book form. Posts to `POST /books`.

| Field | Element | Required |
|-------|---------|----------|
| Title | `input[type=text]` | yes |
| Author | `input[type=text]` | yes |
| Status | `select` from STATUSES | yes |
| Genre | `select` from GENRES | no |
| Rating | Star widget + hidden input | no |
| Notes | `textarea` | no |

Shows `@error` on validation failure. Submitted values are preserved.

---

## edit.erb

Same form as `new.erb` but all fields are pre-filled from `@book`. Star widget pre-fills based on the current `rating`. Posts to `POST /books/:id`.
