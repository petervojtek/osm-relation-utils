module Osm
  class Edge
    #@@edge_counter = 0
      
    attr_accessor :visits, :vertex1, :vertex2
    def initialize vertex1, vertex2
      @vertex1 = vertex1
      @vertex2 = vertex2
      @vertex1.edges << self
      @vertex2.edges << self
      @visits = 0
      @unique_id = "#{@vertex1.unique_id}-#{@vertex2.unique_id}"#@@edge_counter
      #@@edge_counter+= 1
      $logger.debug "just created edge: #{self}"
    end
    
    def complementary_vertex v
      if @vertex1 == v
        return @vertex2
      elsif @vertex2 == v
        return @vertex1
      else
        raise "Edge.complementary_vextex: #{v} is not mine"
      end
    end
    
    def include? v1, v2
      (v1 == @vertex1 && v2 == @vertex2) || (v1 == @vertex2 && v2 == @vertex1) 
    end
    
    def to_s
      "E #{@unique_id} @vertex1:#{@vertex1}, @vertex2:#{@vertex2}"
    end
  end
end