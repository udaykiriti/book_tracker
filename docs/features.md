# Features

---

## Search, Filter and Sort

All three query parameters work together on `GET /books` and can be combined freely.

### Search — `?search=<string>`

Case-insensitive LIKE match across title, author, and genre:

```sql
WHERE (title LIKE '%query%' OR author LIKE '%query%' OR genre LIKE '%query%')
```

### Filter by Status — `?status=<value>`

Value must be in `STATUSES`. Generates:

```sql
WHERE status = 'Completed'
```

### Combined Example

```
GET /books?status=Completed&search=orwell&sort=rating
```

Generates:

```sql
WHERE status = 'Completed'
  AND (title LIKE '%orwell%' OR author LIKE '%orwell%' OR genre LIKE '%orwell%')
ORDER BY rating DESC, id DESC
```

### Sort Options — `?sort=<value>`

| Value | SQL ORDER BY | Description |
|-------|-------------|-------------|
| `newest` (default) | `id DESC` | Most recently added first |
| `oldest` | `id ASC` | Oldest first |
| `title_asc` | `title ASC` | A to Z by title |
| `title_desc` | `title DESC` | Z to A by title |
| `author` | `author ASC` | A to Z by author |
| `rating` | `rating DESC, id DESC` | Highest rated; ties broken by newest |

---

## Session and Flash Messages

Sinatra's cookie-based sessions store one flash entry at a time.

### Flow

```
1.  Route action succeeds (e.g. book created)
2.  set_flash :success, "Book added!"
3.  session[:flash] = { 'type' => 'success', 'msg' => 'Book added!' }
4.  redirect '/books'
5.  Browser follows redirect
6.  layout.erb calls pop_flash
7.  Flash is read and deleted from session in one step
8.  Toast HTML is rendered
9.  JS auto-dismisses the toast after 4 seconds
```

### Flash Types

| Type | When set |
|------|---------|
| `success` | Book created, updated, or deleted |

---

## Star Rating

Books have a 1–5 star rating (0 = unrated).

- **Input**: interactive widget in `new.erb` and `edit.erb` — 5 Font Awesome star icons with hover preview and click-to-set
- **Display**: read-only `render_stars(rating)` helper on book cards and the recent list
- **Sort**: `?sort=rating` orders books by `rating DESC, id DESC`
- **Stats**: average rating shown on the home page stats grid (books with rating 0 are excluded from the average)

---

## Genres

16 preset genre options (Fiction, Non-Fiction, Science Fiction, Fantasy, Mystery, Biography, History, Self-Help, Romance, Thriller, Horror, Science, Philosophy, Poetry, Classic, Other).

- Selected via `<select>` dropdown in forms
- Searchable via `?search=` (genre column is included in the LIKE query)
- Displayed as a badge on book cards if set

---

## Reading Statuses

Five statuses drive the whole tracking system:

| Status | Badge colour |
|--------|-------------|
| To Read | Blue |
| In Progress | Amber |
| Completed | Green |
| On Hold | Purple |
| Dropped | Red |

Status is required on every book. Used for: card top-border accent colour, filter chips, stats grid, recent list badge.
