# proxy.rb for berim
require 'sinatra'
require 'oauth2'
require "./creds.rb"

site_path = 'https://berim.nationbuilder.com'
redirect_uri = 'http://localhost:4567'
client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => site_path)

post '/' do
    token = OAuth2::AccessToken.new(TOKEN)
    "#{params[:data]}"
    response = token.post('/api/v1/sites/berim/pages/blogs/2/posts', :headers => {'Accept' => 'application/json'},
        :params => {'body' : params[:data]})
end

post '/upload' do

end