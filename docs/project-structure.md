# Project Structure

## File Tree

```
book_tracker/
  app.rb                    Entry point — configure Sinatra and load all components
  books.db                  SQLite database (auto-created on first run)
  Gemfile                   Ruby gem declarations
  Gemfile.lock              Locked gem versions
  start.sh                  Shell script to start the server
  README                    Short project overview (plain text)

  config/
    database.rb             DB connection, migrations, STATUSES and GENRES constants

  helpers/
    view_helpers.rb         Flash helpers, star rating HTML, status colour, book stats

  routes/
    home.rb                 GET /
    books.rb                Full CRUD: list, new, create, edit, update, delete

  views/
    layout.erb              Shared HTML shell (navbar, flash toast, footer, FA CDN)
    index.erb               Home page — hero, stats grid, recent books list
    list.erb                Library page — filter chips, search/sort bar, book cards
    new.erb                 Add book form with star rating widget
    edit.erb                Edit book form with prefilled star rating widget

  public/
    css/app.css             All styles — brutalist morphism design system
    js/app.js               Theme toggle (no-FOUC), mobile nav, star widget, toast

  docs/
    README.md               Docs index
    getting-started.md      Quick start and setup
    project-structure.md    This file
    database.md             Schema and constants
    routes.md               HTTP routes
    helpers.md              View helpers
    views.md                ERB templates
    frontend.md             CSS and JS
    features.md             Search, filter, flash
```

## Entry Point — app.rb

`app.rb` is a lean ~18-line file. It configures Sinatra then loads all other components via `require_relative`.

```ruby
require 'sinatra'
require 'sqlite3'
require 'securerandom'

configure do
  set :root,           File.dirname(__FILE__)
  set :public_folder,  File.join(File.dirname(__FILE__), 'public')
  set :views,          File.join(File.dirname(__FILE__), 'views')
  set :bind,           '0.0.0.0'
  set :port,           4567
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
end

require_relative 'config/database'
require_relative 'helpers/view_helpers'
require_relative 'routes/home'
require_relative 'routes/books'
```

| Setting | Value | Notes |
|---------|-------|-------|
| `bind` | `0.0.0.0` | Listens on all interfaces |
| `port` | `4567` | Default Sinatra port |
| `sessions` | enabled | Required for flash messages |
| `session_secret` | env var or random hex | Signs session cookies |
