require 'open-uri'
require 'active_support/core_ext/hash'
require 'logger'

$logger = Logger.new(STDOUT)

module Osm  
  
  class Relation
    attr_accessor :osm_id, :ways
    def initialize osm_id
      @osm_id = osm_id
      @ways = []
      $logger.info "Relation #{@osm_id}: initialized"
    end
    
    def load_from_osm_db
      url = "http://www.openstreetmap.org/api/0.6/relation/#{@osm_id}"
      $logger.info "Relation #{@osm_id}: downloading data from #{url}"
      relation_xml = open(url).read
      
      
      way_ids = extract_way_ids relation_xml
      $logger.info "Relation #{@osm_id}: extracted way ids: #{way_ids}"
      way_ids.each do |way_id|
        w = Way.new(way_id)
        @ways << w
        w.load_from_osm_db
      end
      
    end
    
    def save path_to_file
      File.open(path_to_file, 'wb'){ |f| f.write Marshal.dump(self) }
    end
    
    def to_s
      out = ["Relation #{@osm_id}: #{@ways.size} ways"]
      @ways.each {|w| out << w.to_s}
      out.join("\n")
    end
    
    private
    def extract_way_ids relation_xml
      relation_hash = Hash.from_xml relation_xml
      ways = relation_hash['osm']['relation']['member']
      ways = [ways] if ways.class == Hash
      way_ids = []
      ways.each do |way|
        if way['type'] == 'way'
          way_id = way['ref'].to_i
          way_ids << way_id
        end
      end
      
      return way_ids
    end  
  end
  
  class Way
    attr_accessor :osm_id, :nodes
    def initialize osm_id
      @osm_id = osm_id
      @nodes = []
      $logger.info "Way #{@osm_id}: initialized"
    end
    
    def load_from_osm_db
      url = "http://www.openstreetmap.org/api/0.6/way/#{@osm_id}"
      $logger.info "Way #{@osm_id}: downloading data from #{url}"
      way_xml = open(url).read
      
      node_ids = extract_node_ids way_xml
      $logger.info "Way #{@osm_id}: extracted node ids: #{node_ids}"
      node_ids.each do |node_id|
        n = Node.new(node_id)
        @nodes << n
        n.load_from_osm_db
      end
    end
    
    def to_s
      out = ["  Way #{@osm_id}: #{@nodes.size} nodes"]
      @nodes.each {|n| out << n.to_s}
      out.join("\n")
    end
    
    private
    def extract_node_ids way_xml
      relation_hash = Hash.from_xml way_xml
      nodes = relation_hash['osm']['way']['nd']
      nodes = [nodes] if nodes.class == Hash
      node_ids = []
      nodes.each do |node|
        node_ids << node['ref'].to_i
      end
      
      return node_ids
    end  
  end
  
  class Node
    attr_accessor :osm_id, :lat, :lon
    def initialize osm_id
      @osm_id = osm_id
      $logger.info "Node #{@osm_id}: initialized"
    end
    
    def load_from_osm_db
      url = "http://www.openstreetmap.org/api/0.6/node/#{@osm_id}"
      $logger.info "Node #{@osm_id}: downloading data from #{url}"
      node_xml = open(url).read
      h = Hash.from_xml node_xml
      @lat = h['osm']['node']['lat'].to_f
      @lon = h['osm']['node']['lat'].to_f
      $logger.info "Node #{@osm_id}: extracted latitude:#{@lat}, longitude:#{@lon}"
    end
    
    def to_s
      "    Node #{@osm_id}: latitude:#{@lat}, longitude:#{@lon}"
    end
  end
end

#r = Osm::Relation.new(4437867)
#r.load_from_osm_db
#r.save 'relation-4437867.dump'

r = Marshal.load(File.read('relation-4437867.dump'))
puts r
