helpers do
  def set_flash(type, msg)
    session[:flash] = { 'type' => type.to_s, 'msg' => msg }
  end

  def pop_flash
    session.delete(:flash)
  end

  def status_css(status)
    status.to_s.downcase.gsub(' ', '-')
  end

  # Returns read-only star HTML using Font Awesome icons
  def render_stars(rating)
    r = rating.to_i
    html = '<span class="stars-display">'
    5.times do |i|
      html += i < r \
        ? '<i class="fa-solid fa-star"></i>' \
        : '<i class="fa-regular fa-star"></i>'
    end
    html + '</span>'
  end

  def status_color(status)
    {
      'To Read'     => '#3b82f6',
      'In Progress' => '#f59e0b',
      'Completed'   => '#22c55e',
      'Dropped'     => '#ef4444',
      'On Hold'     => '#a855f7'
    }[status] || '#94a3b8'
  end

  def book_stats
    total = DB.execute('SELECT COUNT(*) AS c FROM books').first['c']
    by_s  = STATUSES.each_with_object({}) do |s, h|
      h[s] = DB.execute('SELECT COUNT(*) AS c FROM books WHERE status = ?', s).first['c']
    end
    avg = DB.execute(
      'SELECT ROUND(AVG(CAST(rating AS FLOAT)),1) AS a FROM books WHERE rating > 0'
    ).first['a']
    { total: total, by_status: by_s, avg_rating: avg }
  end
end
