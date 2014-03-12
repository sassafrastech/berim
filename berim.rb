# berim.rb proxy for berim
require 'oauth2'
require "./creds.rb"
require "sinatra"
require 'json'

site_path = 'https://berim.nationbuilder.com'
client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => site_path)
token = OAuth2::AccessToken.new(client, TOKEN)


configure{ enable :logging }
before {
    env['rack.logger'] = Logger.new("error.log")
}

post '/' do
  logger.info("received post request")
  logger.info(params.inspect)

    f = {
  "attachment" => {
    "filename"=> "test.jpg",
    "content_type" => "image/jpeg",
    "content" => "#{params[:datafile]}"
    }
  }

    response = token.post('/api/v1/sites/berim/pages/blogs/7/attachments',
      :headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'},
      :body => JSON.dump(f)
    )



  # first upload file
  file_response = JSON.parse(response)
  file_url = file_response.nil? ? '' : file_response[:url]


  # build the json for NationBuilder
  d = {
    "blog_post" => {
      "name" => "New Letter from #{params[:name]}",
      "status" => "drafted",
      "content_before_flip" => "Name: #{params[:name]}, Email: #{params[:email]}, Letter: #{params[:letter]}"
    }

  }

  logger.info(JSON.dump(d))

  # send it off to nation builder to create the post
  response = token.post('/api/v1/sites/berim/pages/blogs/7/posts',
    :headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'},
    :body => JSON.dump(d)
  )

  JSON.parse(response.body)
  # redirect to nation builder page, thank you.

end



