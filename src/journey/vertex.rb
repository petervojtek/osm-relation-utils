module Osm
  class Vertex
    @@vertex_counter = 0
    
    attr_accessor :osm_id, :lat, :lon, :visits, :edges, :unique_id
    def initialize lat, lon
      @lat, @lon =  lat, lon
      @visits = 0
      @edges = []
      
      @unique_id = @@vertex_counter
      @@vertex_counter+= 1
      
      $logger.debug "just created vertex: #{self}"
    end
    
    def sort_edges_clockwise!
      neighboring_vertices_and_edges = @edges.collect{ |e| [e.complementary_vertex(self), e]}
      angles_and_edges = neighboring_vertices_and_edges.collect do |neigh_vertex, e|
        angle = bearing_between(self.lat, self.lon, neigh_vertex.lat, neigh_vertex.lon)
        [angle, e]
      end
      
      @edges = angles_and_edges.sort{|a,b| a[0] <=> b[0]}.collect{|angle, edge| edge}
    end
    
    def get_clockwise_edge_suitable_for_visit edge_we_arrived_from
      unless @edges.include?(edge_we_arrived_from)
        raise "error #{self}.get_rightermost_edge_suitable_for_visit: edge #{edge_we_arrived_from} not in list of my edges"
      end
      
      p1 = @edges.find_index edge_we_arrived_from 
      candidates2 = @edges.rotate(p1+1)
       
      candidates2.each do |edge|
        next if edge.visits == 2
        return edge
      end
      
      $logger.info "#{self}.get_clockwise_edge_suitable_for_visit - no suitable edge found"
      return nil
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
    
    def to_s
      "V #{@unique_id}[edges:#{edges.size}, lat:#{@lat} lon:#{@lon}]"
    end
  end
end

