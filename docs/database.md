# Database

**File:** `config/database.rb`

```ruby
DB = SQLite3::Database.new(File.expand_path('../books.db', __dir__))
DB.results_as_hash = true
```

`results_as_hash = true` — every row is returned as a Hash. Access values as `book['title']` not `book[1]`.

## Schema

```sql
CREATE TABLE IF NOT EXISTS books (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  title      TEXT    NOT NULL,
  author     TEXT    NOT NULL,
  status     TEXT    NOT NULL,
  genre      TEXT    DEFAULT '',
  rating     INTEGER DEFAULT 0,
  notes      TEXT    DEFAULT '',
  date_added TEXT    DEFAULT (date('now'))
);
```

| Column | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | INTEGER | — | auto | Primary key, auto-incremented |
| `title` | TEXT | yes | — | Book title |
| `author` | TEXT | yes | — | Author full name |
| `status` | TEXT | yes | — | One of the five STATUSES values |
| `genre` | TEXT | no | `''` | One of the sixteen GENRES values |
| `rating` | INTEGER | no | `0` | Star rating 0 to 5 (0 = unrated) |
| `notes` | TEXT | no | `''` | Free-text personal notes |
| `date_added` | TEXT | no | today | ISO date string YYYY-MM-DD |

## Safe Migrations

New columns are added to existing databases without data loss. The loop rescues `SQLite3::Exception` if the column already exists — safe against both fresh and legacy databases.

```ruby
{
  'genre'      => "TEXT DEFAULT ''",
  'rating'     => 'INTEGER DEFAULT 0',
  'notes'      => "TEXT DEFAULT ''",
  'date_added' => "TEXT DEFAULT ''"
}.each do |col, defn|
  begin
    DB.execute("ALTER TABLE books ADD COLUMN #{col} #{defn}")
  rescue SQLite3::Exception
    # Column already exists — skip silently
  end
end
```

> Note: `ALTER TABLE ADD COLUMN` in SQLite requires a constant literal default. `DEFAULT (date('now'))` only works in `CREATE TABLE`, so migrations use `DEFAULT ''` for `date_added`.

## Constants

### STATUSES

```ruby
STATUSES = ['To Read', 'In Progress', 'Completed', 'Dropped', 'On Hold'].freeze
```

Every `status` written to the database is validated against this array. POST requests with an unlisted status are rejected with a validation error.

### GENRES

```ruby
GENRES = [
  'Fiction', 'Non-Fiction', 'Science Fiction', 'Fantasy', 'Mystery',
  'Biography', 'History', 'Self-Help', 'Romance', 'Thriller',
  'Horror', 'Science', 'Philosophy', 'Poetry', 'Classic', 'Other'
].freeze
```

Genre is optional and not server-validated. This list populates the genre `<select>` in forms.
