# Routes

## Home

**File:** `routes/home.rb`

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Home page — stats + 6 most recently added books |

```ruby
get '/' do
  @stats  = book_stats
  @recent = DB.execute('SELECT * FROM books ORDER BY id DESC LIMIT 6')
  erb :index
end
```

---

## Books CRUD

**File:** `routes/books.rb`

| Method | Path | Description |
|--------|------|-------------|
| GET | `/books` | List all books — supports `?search=`, `?status=`, `?sort=` |
| GET | `/books/new` | Render the add-book form |
| POST | `/books` | Create a new book |
| GET | `/books/:id/edit` | Render the edit form for a book |
| POST | `/books/:id` | Update a book |
| POST | `/books/:id/delete` | Delete a book |

---

### GET /books — step by step

1. Read `params[:status]`, `params[:search]`, `params[:sort]` from the query string.
2. Determine `ORDER BY` from the sort option (defaults to `id DESC`).
3. Build `conds` (SQL condition strings) and `binds` (bind values) arrays.
4. If `status` is present and valid, push `status = ?` onto conds.
5. If `search` is non-empty, push `(title LIKE ? OR author LIKE ? OR genre LIKE ?)` with `%search%` wildcards.
6. Join conds with `AND` to form the `WHERE` clause.
7. Execute the query, assign results to `@books`.
8. Run per-status COUNT queries for `@counts` (powers the filter chip counts).

See [features.md](features.md) for full search/filter/sort details.

---

### POST /books — validation

- `title` — required, non-empty after strip
- `author` — required, non-empty after strip
- `status` — must be in `STATUSES`
- `rating` — clamped to 0–5: `[[params[:rating].to_i, 0].max, 5].min`
- `genre`, `notes` — optional

On success: sets flash + redirects to `/books`.
On failure: re-renders the form with `@error` and submitted values preserved in `@book`.

---

### POST /books/:id/delete

Fetches the book title before deleting (for the flash message), then deletes and redirects.

```ruby
post '/books/:id/delete' do
  book = DB.execute('SELECT title FROM books WHERE id = ?', params[:id]).first
  DB.execute('DELETE FROM books WHERE id = ?', params[:id])
  set_flash :success, "\"#{book['title']}\" removed from your library." if book
  redirect '/books'
end
```

---

### GET /books/:id/edit

Halts with 404 if the book does not exist:

```ruby
get '/books/:id/edit' do
  @book = DB.execute('SELECT * FROM books WHERE id = ?', params[:id]).first
  halt 404 unless @book
  erb :edit
end
```
