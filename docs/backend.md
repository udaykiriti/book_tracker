# Backend

Everything that runs server-side: Sinatra configuration, request lifecycle, database layer, route logic, helpers, and session handling.

---

## Stack

| Layer | Technology | Role |
|-------|-----------|------|
| Language | Ruby 4.0+ | Application code |
| Framework | Sinatra 4.2 | HTTP routing and request/response |
| Server | Puma 6.x | Multi-threaded HTTP server |
| Rack adapter | Rackup | Rack CLI required by Sinatra 4+ |
| Database | SQLite3 | Embedded relational database |
| ORM | None | Raw SQL via the `sqlite3` gem |
| Templating | ERB | Embedded Ruby in `.erb` view files |
| Sessions | Sinatra built-in | Cookie-based, signed with a secret |

---

## Request Lifecycle

```
Browser request
      |
      v
Puma (HTTP server)
      |
      v
Rack middleware stack
      |
      v
Sinatra router — matches method + path
      |
      v
Route block executes
  - reads params
  - queries DB via raw SQL
  - calls helpers if needed
  - sets instance variables (@books, @stats, etc.)
      |
      v
ERB template rendered (layout.erb wraps the page template)
      |
      v
HTML response sent to browser
```

On POST routes (create, update, delete):

```
Route block executes
  - validates input
  - writes to DB
  - calls set_flash
  - calls redirect
      |
      v
302 redirect response
      |
      v
Browser follows redirect → GET request → normal lifecycle
```

---

## File Loading Order

`app.rb` loads components in this exact order:

```ruby
require_relative 'config/database'      # 1. DB connection + constants
require_relative 'helpers/view_helpers' # 2. Helper methods registered
require_relative 'routes/home'          # 3. GET / route defined
require_relative 'routes/books'         # 4. All /books routes defined
```

Each file is loaded once at boot. The order matters: routes use helpers and DB, so those must be loaded first.

---

## config/database.rb

Three responsibilities:

1. **Open the database connection**

```ruby
DB = SQLite3::Database.new(File.expand_path('../books.db', __dir__))
DB.results_as_hash = true
```

`DB` is a global constant. `results_as_hash = true` makes all query results return as `Hash` instead of `Array`, so columns are accessed by name (`book['title']`) not index.

2. **Run CREATE TABLE on boot**

```sql
CREATE TABLE IF NOT EXISTS books (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  title      TEXT NOT NULL,
  author     TEXT NOT NULL,
  status     TEXT NOT NULL,
  genre      TEXT DEFAULT '',
  rating     INTEGER DEFAULT 0,
  notes      TEXT DEFAULT '',
  date_added TEXT DEFAULT (date('now'))
);
```

`IF NOT EXISTS` makes this idempotent — safe to run on every boot.

3. **Run safe column migrations**

Uses `ALTER TABLE ADD COLUMN` wrapped in `rescue SQLite3::Exception` to add columns that may not exist in older databases. ALter TABLE in SQLite requires a constant literal as a default value, so `date_added` uses `DEFAULT ''` in the migration even though `CREATE TABLE` uses `DEFAULT (date('now'))`.

---

## helpers/view_helpers.rb

Registered with Sinatra's `helpers do ... end` block so all methods are available in both route blocks and ERB views.

### set_flash / pop_flash

Session-based one-shot flash messages:

```ruby
def set_flash(type, msg)
  session[:flash] = { 'type' => type.to_s, 'msg' => msg }
end

def pop_flash
  session.delete(:flash)   # reads AND deletes in one call
end
```

### render_stars(rating)

Generates read-only HTML for a star rating using Font Awesome icons. No JavaScript required for display — pure server-rendered HTML.

### status_css(status)

```ruby
def status_css(status)
  status.to_s.downcase.gsub(' ', '-')
  # 'In Progress' => 'in-progress'
end
```

Used to build CSS class names for status-specific styling without a lookup table.

### status_color(status)

Returns a hex colour string used inline (`style="border-top-color: ..."`) on book cards so each status has its own accent colour.

### book_stats

Runs 7 SQL queries (1 total + 5 per-status + 1 average) and returns a single Hash. Called only on the home route.

---

## routes/home.rb

Single route, minimal logic:

```ruby
get '/' do
  @stats  = book_stats
  @recent = DB.execute('SELECT * FROM books ORDER BY id DESC LIMIT 6')
  erb :index
end
```

---

## routes/books.rb

### Query building pattern (GET /books)

Uses array accumulation to safely build parameterised SQL:

```ruby
conds = []
binds = []

if @status_filter && STATUSES.include?(@status_filter)
  conds << 'status = ?'
  binds << @status_filter
end

if @search && !@search.empty?
  conds << '(title LIKE ? OR author LIKE ? OR genre LIKE ?)'
  binds += ["%#{@search}%", "%#{@search}%", "%#{@search}%"]
end

where  = conds.empty? ? '' : "WHERE #{conds.join(' AND ')}"
@books = DB.execute("SELECT * FROM books #{where} ORDER BY #{order}", binds)
```

All user input goes through `?` placeholders — no string interpolation of user data, no SQL injection risk.

### Sort options map

```ruby
order = case @sort
        when 'title_asc'  then 'title ASC'
        when 'title_desc' then 'title DESC'
        when 'author'     then 'author ASC'
        when 'rating'     then 'rating DESC, id DESC'
        when 'oldest'     then 'id ASC'
        else                   'id DESC'         # 'newest' default
        end
```

`order` is built from a whitelist of known values, not from user input, so it is safe to interpolate directly into the SQL string.

### Input validation pattern (POST /books and POST /books/:id)

```ruby
title  = params[:title]&.strip
author = params[:author]&.strip
rating = [[params[:rating].to_i, 0].max, 5].min   # clamp 0..5

if title && !title.empty? && author && !author.empty? && STATUSES.include?(status)
  # write to DB, flash, redirect
else
  @error = 'Title and author are required.'
  @book  = { 'title' => title, ... }   # re-populate form
  erb :new   # or :edit
end
```

The `&.strip` (safe navigation) handles `nil` params without raising. Rating is clamped server-side regardless of what the client sends.

### Delete safety

The book title is fetched before deletion so the flash message can name the deleted book:

```ruby
book = DB.execute('SELECT title FROM books WHERE id = ?', params[:id]).first
DB.execute('DELETE FROM books WHERE id = ?', params[:id])
set_flash :success, "\"#{book['title']}\" removed." if book
```

If the ID doesn't exist, `book` is `nil`, deletion is a no-op, and no flash is set.

---

## Session and Security

| Concern | Implementation |
|---------|---------------|
| Session storage | Sinatra cookie-based sessions (signed, not encrypted) |
| Session secret | `ENV['SESSION_SECRET']` or `SecureRandom.hex(64)` at boot |
| SQL injection | All user input passed via `?` bind parameters |
| Status validation | Server-side check against `STATUSES` constant |
| Rating validation | Clamped to `0..5` server-side |
| CSRF | Not implemented (Sinatra does not include CSRF protection by default) |

> For production deployments, add a CSRF token to forms and validate it in POST routes.

---

## Database Access Patterns

All queries use the global `DB` constant directly. No ORM, no repository layer.

| Operation | SQL pattern |
|-----------|------------|
| Read all | `DB.execute("SELECT * FROM books ...")` |
| Read one | `DB.execute("SELECT * FROM books WHERE id = ?", id).first` |
| Insert | `DB.execute("INSERT INTO books (...) VALUES (...)", [...])` |
| Update | `DB.execute("UPDATE books SET ...=? WHERE id=?", [...])` |
| Delete | `DB.execute("DELETE FROM books WHERE id = ?", id)` |
| Count | `DB.execute("SELECT COUNT(*) AS c FROM books").first['c']` |
| Average | `DB.execute("SELECT ROUND(AVG(...), 1) AS a FROM books ...").first['a']` |

---

## Error Handling

| Scenario | Behaviour |
|----------|----------|
| Book not found (edit) | `halt 404` — Sinatra returns a 404 response |
| Invalid status on POST | Validation fails, form re-rendered with `@error` |
| Empty title or author | Validation fails, form re-rendered with `@error` |
| DB column already exists | `rescue SQLite3::Exception` in migration loop — silently skipped |
| Unknown sort value | Falls through to `else 'id DESC'` in the case statement |
