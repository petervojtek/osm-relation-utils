module Osm
  class Way
    @@way_counter = 0
    attr_accessor :osm_id, :nodes, :simplified_id
    def initialize osm_id
      @osm_id = osm_id
      @nodes = []
      @simplified_id = @@way_counter
      @@way_counter += 1
      $logger.info "Way #{@osm_id}: initialized"
    end
    
    def load_from_osm_db
      url = "http://www.openstreetmap.org/api/0.6/way/#{@osm_id}"
      $logger.info "Way #{@osm_id}: downloading data from #{url}"
      way_xml = open(url).read
      
      node_ids = extract_node_ids way_xml
      $logger.info "Way #{@osm_id}: extracted node ids: #{node_ids}"
      node_ids.each do |node_id|
        n = Node.new(node_id, self)
        @nodes << n
        n.load_from_osm_db
      end
    end
    
    def to_s
      out = ["  W#{@simplified_id} [OSM #{@osm_id}] #{@nodes.size} nodes"]
      @nodes.each {|n| out << n.to_s}
      out.join("\n")
    end
    
    def end_nodes
      [@nodes.first, @nodes.last]
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
end