get '/books' do
  @status_filter = params[:status]
  @search        = params[:search]&.strip
  @sort          = params[:sort] || 'newest'

  order = case @sort
          when 'title_asc'  then 'title ASC'
          when 'title_desc' then 'title DESC'
          when 'author'     then 'author ASC'
          when 'rating'     then 'rating DESC, id DESC'
          when 'oldest'     then 'id ASC'
          else 'id DESC'
          end

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

  where   = conds.empty? ? '' : "WHERE #{conds.join(' AND ')}"
  @books  = DB.execute("SELECT * FROM books #{where} ORDER BY #{order}", binds)
  @counts = STATUSES.each_with_object(
    { 'all' => DB.execute('SELECT COUNT(*) AS c FROM books').first['c'] }
  ) do |s, h|
    h[s] = DB.execute('SELECT COUNT(*) AS c FROM books WHERE status = ?', s).first['c']
  end

  erb :list
end

get '/books/new' do
  erb :new
end

post '/books' do
  title  = params[:title]&.strip
  author = params[:author]&.strip
  status = params[:status]
  genre  = params[:genre]&.strip.to_s
  rating = [[params[:rating].to_i, 0].max, 5].min
  notes  = params[:notes]&.strip.to_s

  if title && !title.empty? && author && !author.empty? && STATUSES.include?(status)
    DB.execute(
      'INSERT INTO books (title, author, status, genre, rating, notes, date_added) ' \
      'VALUES (?, ?, ?, ?, ?, ?, date("now"))',
      [title, author, status, genre, rating, notes]
    )
    set_flash :success, "\"#{title}\" added to your library!"
    redirect '/books'
  else
    @error = 'Title and author are required.'
    @book  = { 'title' => title, 'author' => author, 'status' => status,
               'genre' => genre, 'rating' => rating, 'notes' => notes }
    erb :new
  end
end

get '/books/:id/edit' do
  @book = DB.execute('SELECT * FROM books WHERE id = ?', params[:id]).first
  halt 404 unless @book
  erb :edit
end

post '/books/:id' do
  title  = params[:title]&.strip
  author = params[:author]&.strip
  status = params[:status]
  genre  = params[:genre]&.strip.to_s
  rating = [[params[:rating].to_i, 0].max, 5].min
  notes  = params[:notes]&.strip.to_s

  if title && !title.empty? && author && !author.empty? && STATUSES.include?(status)
    DB.execute(
      'UPDATE books SET title=?, author=?, status=?, genre=?, rating=?, notes=? WHERE id=?',
      [title, author, status, genre, rating, notes, params[:id]]
    )
    set_flash :success, "\"#{title}\" updated successfully!"
    redirect '/books'
  else
    @error = 'Title and author are required.'
    @book  = { 'id' => params[:id], 'title' => title, 'author' => author,
               'status' => status, 'genre' => genre, 'rating' => rating, 'notes' => notes }
    erb :edit
  end
end

post '/books/:id/delete' do
  book = DB.execute('SELECT title FROM books WHERE id = ?', params[:id]).first
  DB.execute('DELETE FROM books WHERE id = ?', params[:id])
  set_flash :success, "\"#{book['title']}\" removed from your library." if book
  redirect '/books'
end
