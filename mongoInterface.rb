require 'sinatra/base'
require 'mongo'
require 'pry'
require 'haml'
require 'sass'
require 'rack-flash'


class MongoInterface < Sinatra::Base

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

	  column_id = columnsCollection.insert(to_insert_to_columns)

	  begin
	  	user_id_to_update = usersCollection.find({"login" => session[:login]}).find.each{|i| p i}['_id']
	  rescue Exception => e
	  	puts "the user you want to add columns to couldn't be found. Here is the error message : #{e.message}"
	  end

		usersCollection.update( {"_id" => user_id_to_update }, {"$set" => {"columns" => column_id }} )

		flash[:notice] = "Here is the user_id from users collection to be inserted in shore : #{user_id_to_update}"

	  #binding.pry
	  redirect '/'
	end

helpers do
	def client
		@client ||= Mongo::Connection.new("mongocfg1.fetcher")
	end
	def db
		db ||= client['test']
	end
	def columnsCollection
		coll ||= db['columns']
	end
	def usersCollection
		coll ||= db['users']
	end
end

end