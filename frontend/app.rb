require 'sinatra'
require_relative '../background/lib/hubhop'
require 'sinatra/reloader' if development?
require 'sinatra/flash'
require 'json'

enable :sessions

get '/' do
  redirect '/request/create'
end

get '/request/create' do
  @errors = json_parse(params[:errors])
  @form_data = json_parse(params[:form_data])
  haml :index, layout: :app
end

post '/request/new' do
  errors = HubHop::Validator.validate_input process params

  if errors.size > 0
    redirect "/request/create?errors=#{to_url(errors)}&" +
      "form_data=#{to_url(params)}"
  else
    begin
      req_id = HubHop::Request.new.start_search(process params)
    rescue => err
      redirect "/request/create?errors=#{to_url({global: err.message})}&" +
        "form_data=#{to_url(params)}"
    end
    flash[:notice] = "New request created"
    redirect "/request/#{req_id}"
  end
end

get '/request/:req_id' do |req_id|
  @req_id = req_id
  @flash_message = flash[:notice] || ""
  @ready = HubHop::Request.new(req_id).check
  haml :check, layout: :app
end


helpers do
  def to_url(object)
    URI.escape object.to_json
  end
  def json_parse(data)
    JSON.parse(data || "{}").deep_symbolize_keys
  end

  def process(data)
    allowed = [:from_place, :to_place,
              :via_place, :from_date,
              :to_date, :max_transit_time]
    airport_lists = [:from_place, :to_place, :via_place]
    dates = [:from_date, :to_date]
    ints = [:max_transit_time]

    data.
      deep_symbolize_keys.
      # Filter out not allowed fields
      select { |k,v|
        allowed.include? k
      }.
      inject({}) { |hash, (k,v)|
        # Clean up airport lists
        if airport_lists.include? k
          hash[k] = v.gsub(/\s+/, "").split(",")
        end
        # Clean up dates
        if dates.include? k
          hash[k] = Date.parse(v).strftime("%Y-%m-%d")
        end
        # Clean up integers
        if ints.include? k
          hash[k] = v.to_i
        end
        hash
      }
  end

  def default_for_type(type)
    case type
    when "text"
      "LED, DME"
    else
      ""
    end
  end
end
