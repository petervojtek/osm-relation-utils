module Osm
  class Vertex
    attr_accessor :osm_id, :lat, :lon, :visits
    def initialize osm_id, lat, lon
      @osm_id, @lat, @lon = osm_id, lat, lon
      @visits = 0
      @edges = []
    end
    
    def sort_edges_clockwise!
      neighboring_vertices = self.edges.collect{ |e| e.complementary_vextex(self)}
      angles_and_neigh_vertices = neighboring_vertices.collect do |neigh_vertex|
        angle = bearing_between(self.lat, self.lon, neigh_vertex.lat, neigh_vertex.lon)
        [angle, neigh_vertex]
      end
      
      @edges = angles_and_neigh_vertices.sort{|a,b| a[0] <=> b[0]}.select{|angle, vertex| vertex}
    end
    
    def get_clockwise_edge_suitable_for_visit edge_we_arrived_from
      unless self.edges.include?(edge_we_arrived_from)
        raise "error #{self}.get_rightermost_edge_suitable_for_visit: edge #{edge_we_arrived_from} not in list of my edges"
      end
      
      candidates1 = self.edges
      p1 = candidates1[edge_we_arrived_from]
      candidates2 = candidates1.rotate(p1+1)
       
      candidates2.each do |edge|
        next if edge.visits == 2
        return edge
      end
      
      raise "error #{self}.get_rightermost_edge_suitable_for_visit - no suitable edge found"
    end
    
    # http://www.rubydoc.info/gems/rails-geocoder/0.9.11/Geocoder/Calculations#bearing_between-instance_method
    def bearing_between(lat1, lon1, lat2, lon2, options = {})
      options[:method] = :linear unless options[:method] == :spherical

      # convert degrees to radians
      lat1, lon1, lat2, lon2 = to_radians(lat1, lon1, lat2, lon2)

      # compute deltas
      dlat = lat2 - lat1
      dlon = lon2 - lon1

      case options[:method]
      when :linear
        y = dlon
        x = dlat

      when :spherical
        y = Math.sin(dlon) * Math.cos(lat2)
        x = Math.cos(lat1) * Math.sin(lat2) -
          Math.sin(lat1) * Math.cos(lat2) * Math.cos(dlon)
      end

      bearing = Math.atan2(x,y)
      # Answer is in radians counterclockwise from due east.
      # Convert to degrees clockwise from due north:
      (90 - to_degrees(bearing) + 360) % 360
    end
    
    def to_radians(*args)
      args = args.first if args.first.is_a?(Array)
      if args.size == 1
        args.first * (Math::PI / 180)
      else
        args.map{ |i| to_radians(i) }
      end
    end
    
    def to_degrees(*args)
      args = args.first if args.first.is_a?(Array)
      if args.size == 1
        (args.first * 180.0) / Math::PI
      else
        args.map{ |i| to_degrees(i) }
      end
    end
  end
end

