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
    
    def to_s
      out = ["  W#{@simplified_id} [OSM #{@osm_id}] #{@nodes.size} nodes"]
      @nodes.each {|n| out << n.to_s}
      out.join("\n")
    end
    
    def end_nodes
      [@nodes.first, @nodes.last]
    end 
  end
end