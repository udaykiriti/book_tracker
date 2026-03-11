get '/' do
  @stats  = book_stats
  @recent = DB.execute('SELECT * FROM books ORDER BY id DESC LIMIT 6')
  erb :index
end
