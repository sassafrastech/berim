# proxy.rb for berim
require 'oauth2'
require "./creds.rb"
require "sinatra"

site_path = 'https://berim.nationbuilder.com'
redirect_uri = 'http://localhost:4567'
client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => site_path)

configure{ enable :logging }
before { env['rack.logger'] = Logger.new("/home/tomsmyth/webapps/berim/log/error.log")}
  
post '/' do
  logger.info("jill PLESE WORK!")
  token = OAuth2::AccessToken.new(client, TOKEN)
  logger.info("HALLO!!")
  response = token.post('/api/v1/sites/berim/pages/blogs/2/posts', :headers => {'Accept' => 'application/json'},
    :params => {'body' => params[:data]})
  logger.info("Got past response")
end

get '/' do
  logger.info("tester")
  "HOWDDD"

end

