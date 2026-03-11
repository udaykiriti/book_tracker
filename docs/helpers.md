# Helpers

**File:** `helpers/view_helpers.rb`

Registered with `helpers do ... end` — available in all routes and ERB templates.

---

## set_flash(type, msg)

Stores a flash message in the session for the next page load.

```ruby
set_flash :success, "Book added!"
# Stores: session[:flash] = { 'type' => 'success', 'msg' => 'Book added!' }
```

---

## pop_flash

Reads and deletes the flash from the session. Returns `nil` if nothing is stored. Called once per request in `layout.erb`.

---

## render_stars(rating)

Returns an HTML string of 5 Font Awesome star icons.

- Positions 1 to `rating` → `fa-solid fa-star` (filled)
- Remaining positions → `fa-regular fa-star` (outline)

Used for read-only star display on book cards and the recent list.

---

## status_css(status)

Converts a status string to a CSS-safe class name.

```ruby
status_css('In Progress')  # => 'in-progress'
status_css('To Read')      # => 'to-read'
status_css('On Hold')      # => 'on-hold'
```

---

## status_color(status)

Returns the hex colour for a status. Used to set the `border-top-color` accent on book cards.

| Status | Colour | Hex |
|--------|--------|-----|
| To Read | Blue | `#3b82f6` |
| In Progress | Amber | `#f59e0b` |
| Completed | Green | `#22c55e` |
| Dropped | Red | `#ef4444` |
| On Hold | Purple | `#a855f7` |

---

## book_stats

Queries the database and returns a summary Hash for the home page stats grid.

```ruby
{
  total:      Integer,
  by_status:  {
    'To Read'     => Integer,
    'In Progress' => Integer,
    'Completed'   => Integer,
    'Dropped'     => Integer,
    'On Hold'     => Integer
  },
  avg_rating: Float or nil   # nil if no books have rating > 0
}
```

Average rating query:

```sql
SELECT ROUND(AVG(CAST(rating AS FLOAT)), 1) AS a
FROM books WHERE rating > 0
```
