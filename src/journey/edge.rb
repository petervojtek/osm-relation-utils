module Osm
  class Edge
    attr_accessor :visits
    def initialize vertex1, vertex2
      @vertex1 = vertex1
      @vertex2 = vertex2
      @visits = 0
    end
    
    def complementary_vextex v
      if @vertex1 == v
        return @vertex2
      elsif @vertex2 == v
        return @vertex2
      else
        raise "Edge.complementary_vextex: #{v} is not mine"
      end
    end
  end
end