# berim.rb proxy for berim
require 'oauth2'
require "./creds.rb"
require "sinatra"
require 'json'
require 'base64'
include FileUtils::Verbose

site_path = 'https://berim.nationbuilder.com'
client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, :site => site_path)
token = OAuth2::AccessToken.new(client, TOKEN)


configure{ enable :logging }
before {
  env['rack.logger'] = Logger.new("error.log")
}

post '/' do

  begin
    # if there is a file, upload it and get url
    file_url = params['datafile'] ? upload_file(params['datafile'], token) : nil

    upload_post(params, token, file_url)

    # redirect to success page
    redirect 'http://www.berim.org/letter_submitted'
  rescue
    logger.info("General failure: #{$!}")
    # render failure
    send_file('berim-error.html')
  end

end

# upload post to NationBuilder
# returns response
def upload_post(params, token, file_url)
  # build the json for NationBuilder

  img_chunk = file_url.nil? ? '' : "File: <img src='#{file_url}'/>"

  post = {
    "blog_post" => {
      "name" => "New Letter from #{params[:name]}",
      "status" => "drafted",
      "content_before_flip" => "Name: #{params[:name]}, Email: #{params[:email]}, Letter: #{params[:letter]} #{img_chunk}"
    }
  }

  # send it off to nation builder to create the post
  response = token.post('/api/v1/sites/berim/pages/blogs/7/posts',
    :headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'},
    :body => JSON.dump(post)
  )

  unless response.status == 200
    logger.info("Blog post failed: #{response.body}")
    raise 'post failed'
  end

end

# upload file to NationBuilder page attachments
# returns url of file on NationBuilder
def upload_file(file, token)

  # encode attachment
  encoded_file = Base64.strict_encode64(file[:tempfile].read)

  # create JSON
  fdata = {
    "attachment" => {
      "filename" => params['datafile'][:filename],
      "content_type" => "image/jpeg",
      "updated_at" => "2013-06-06T10:15:02-07:00",
      "content" => encoded_file
    }
  }

  # post the request
  response = token.post('/api/v1/sites/berim/pages/letter_attachments/attachments',
    :headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'},
    :body => JSON.dump(fdata)
  )

  unless response.status == 200
    logger.info("Upload failed: #{response.body}")
    raise 'upload failed'
  end

  return JSON.parse(response.body)['attachment']['url']

end



