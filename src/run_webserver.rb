require 'open-uri'
require 'active_support/core_ext/hash'
require 'logger'
require 'erb'
require 'nokogiri'

require './node.rb'
require './way.rb'
require './relation.rb'

require './journey/vertex.rb'
require './journey/edge.rb'
require './journey/journey.rb'

require 'sinatra'

$logger = Logger.new(STDOUT)  
$logger.level = Logger::INFO

set :public_folder, 'html'
set :port, ARGV[0]

get '/relation/:id' do
  r = Osm::Relation.new(params[:id].to_i)
  r.load
  r.determine_interconnections
  r.to_html

  j = Osm::Journey.new r
  j.generate_journey
  j.to_html
  j.to_gpx

  redirect to "journey-#{r.osm_id}.html" 
end