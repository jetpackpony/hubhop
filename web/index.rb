Bundler.require

get '/' do
  erb :form
end

post '/search' do
  erb :form
  params.inspect
end
