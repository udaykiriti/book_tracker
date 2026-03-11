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
