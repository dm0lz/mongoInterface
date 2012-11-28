require 'mongo'
require 'pry'
require 'sinatra'
require 'haml'
require 'sass'
require 'rack-flash'


class MongoInterface < Sinatra::Base

include Mongo

set :haml, :format => :html5
use Rack::Flash
enable :sessions

get '/style.css' do
	sass :style
end

get '/' do
	@flash = flash[:notice]
  haml :index
end

post '/resultat' do
	session[:filter] = params[:filter]
  session[:streamType] = params[:streamType]
  session[:streamArgument] = params[:streamArgument]
  session[:login] = params[:login]

  redirect '/resultat'
end

get '/resultat' do
	
	@client =  client
	@db = db
	@columnsCollection = columnsCollection
	@usersCollection = usersCollection

	filter = session[:filter] 
  streamType = session[:streamType]
  streamArgument = session[:streamArgument].split
  login = session[:login] 
  
 to_insert_to_columns = { 
 	"filter"=>
  [{"type"=>"text",
    "property"=>"articleBody",
    "operator"=>"includes",
    "value"=>[filter]}],
 "source"=>
  [{"streamType"=> streamType,
    "streamArgument"=> streamArgument,
    "provider"=>"twitter",
    "endpoint"=>"user",
    "viewer"=>308762265.0}] 
  }

  @columnsCollection.insert(to_insert_to_columns)
  column_id = @columnsCollection.find.sort(:_id => :desc ).limit(1).find.each {|i| p i} ['_id']
  
  to_insert_to_users = { 
  "columns"=>[column_id],
  "login"=>login 
	}

	@usersCollection.insert(to_insert_to_users)

	user_id = @usersCollection.find.sort(:_id => :desc ).limit(1).find.each {|i| p i} ['_id']

	flash[:notice] = "Here is the user_id from users collection to be inserted in shore : #{user_id}"

  #binding.pry
  redirect '/'
end

helpers do
	def client
		@client = Mongo::Connection.new("mongocfg1.fetcher")
	end
	def db
		@db = @client['test']
	end
	def columnsCollection
		@coll = @db['columns']
	end
	def usersCollection
		@coll = @db['users']
	end
end

end