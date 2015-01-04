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
    
    def get_edge_suitable_for_visit edge_we_arrived_from
      unless @edges.include?(edge_we_arrived_from)
        raise "error #{self}.get_rightermost_edge_suitable_for_visit: edge #{edge_we_arrived_from} not in list of my edges"
      end
      
      e = @edges.sort{|a,b| a.visits <=> b.visits}.first
      
      h = {}
      @edges.each do |e|
        h[e.visits] ||= []
        h[e.visits] << e
      end
      

      lowest_number_of_visits = h.keys.sort.first
      edges_with_lowest_number_of_visits = h[lowest_number_of_visits]
      
      angle_of_edge_we_arrived_from = angle_of edge_we_arrived_from # against north
      angles_and_edges = array_of_angles_and_arrays edges_with_lowest_number_of_visits
      _, first_edge_right_of_edge_we_arrived_from = angles_and_edges.collect{|a, e| [a + 360, e]}.find{|angle, edge| angle > angle_of_edge_we_arrived_from}
      
      if first_edge_right_of_edge_we_arrived_from.visits > 5
        # prevent us from 100% cpu utilization in case of some bug
        return nil
      else
        return e
      end
    end
    
    def array_of_angles_and_arrays edges
      neighboring_vertices_and_edges = edges.collect{ |e| [e.complementary_vertex(self), e]}
      angles_and_edges = neighboring_vertices_and_edges.collect do |neigh_vertex, e|
        angle = bearing_between(self.lat, self.lon, neigh_vertex.lat, neigh_vertex.lon)
        [angle, e]
      end
      
      angles_and_edges
    end
    
    def angle_of edge
      lat2, lon2 = edge.complementary_vertex(self).lat, edge.complementary_vertex(self).lon
      bearing_between(self.lat, self.lon, lat2, lon2)
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

