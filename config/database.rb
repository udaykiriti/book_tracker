DB = SQLite3::Database.new(File.expand_path('../books.db', __dir__))
DB.results_as_hash = true

DB.execute <<-SQL
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
SQL

# Safely add new columns to existing databases
{
  'genre'      => "TEXT DEFAULT ''",
  'rating'     => 'INTEGER DEFAULT 0',
  'notes'      => "TEXT DEFAULT ''",
  'date_added' => "TEXT DEFAULT ''"   # ALTER TABLE requires a constant default
}.each do |col, defn|
  begin
    DB.execute("ALTER TABLE books ADD COLUMN #{col} #{defn}")
  rescue SQLite3::Exception
    # Column already exists — skip
  end
end

STATUSES = ['To Read', 'In Progress', 'Completed', 'Dropped', 'On Hold'].freeze

GENRES = [
  'Fiction', 'Non-Fiction', 'Science Fiction', 'Fantasy', 'Mystery',
  'Biography', 'History', 'Self-Help', 'Romance', 'Thriller',
  'Horror', 'Science', 'Philosophy', 'Poetry', 'Classic', 'Other'
].freeze
