require 'sinatra'

get '/' do
  erb :index
end

post '/crawl' do
 params['url']
end