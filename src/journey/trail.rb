module Osm
  class Journey
    def initialize 
      @vertices = [] # must be 1-component graph
      @edges = []
      @journey = []
    end
    
    
    def generate_trail
      vertex = @vertices.first
      travel_to vertex, nil
    end
    
    def travel_to vertex, edge_we_arrived_from
      
      if(edge_we_arrived_from) # nil if we just begin our trail
        edge_we_arrived_from.visits += 1
        @journey << edge_we_arrived_from
      end
      
      vertex.visits += 1
      @journey << vertex
      
      next_vertex, edge_we_will_travel_next = determine_next_hop vertex, edge_we_arrived_from
      if next_vertex
        travel_to next_vertex, edge_we_will_travel_next
      else
        puts "finished"
      end
    end
    
    def determine_next_hop vertex, edge_we_arrived_from
      if edge_we_arrived_from.nil? # special case (initial vertex)
        edge_we_will_travel_next = vertex.edges.first
      else
        edge_we_will_travel_next = vertex.get_clockwise_edge_suitable_for_visit(edge_we_arrived_from)
      end
      
      next_vertex = edge_we_will_travel_next.complementary_vextex(vertex)
      [next_vertex, edge_we_will_travel_next]
    end
  end
end