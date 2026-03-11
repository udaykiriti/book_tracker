# Getting Started

## Requirements

- Ruby (tested on 4.0.1)
- Bundler

## Install

```bash
bundle install --path vendor/bundle
```

## Start the Server

```bash
# Via the startup script
./start.sh

# Or directly
bundle exec ruby app.rb
```

Output on start:

```
== Sinatra (v4.2.1) has taken the stage on 4567 for development with backup from Puma
* Listening on http://0.0.0.0:4567
```

Open http://localhost:4567 in your browser.

## Stop the Server

Press `Ctrl+C` in the terminal, or send SIGTERM to the PID shown in the startup output.

## Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `SESSION_SECRET` | Random 64-char hex | Signs session cookies. Set to a fixed value in production so sessions survive server restarts. |

Example:

```bash
export SESSION_SECRET="replace-with-a-long-random-string"
bundle exec ruby app.rb
```

## Gems

```ruby
gem 'sinatra'   # Web framework
gem 'sqlite3'   # SQLite adapter
gem 'puma'      # HTTP server
gem 'rackup'    # Rack CLI (required by Sinatra 4+)
```
