module Osm
  class Journey
    def initialize relation
      @vertices = [] # must be 1-component graph
      @edges = []
      @journey_points = []
      @relation = relation
      
      populate_vertices_and_edges
    end
    
    def generate_journey
      vertex = @vertices.first
      $logger.info "Journey.generate_journey: starting journey with vertex #{vertex}"
      travel_to vertex, nil
    end
    
    def to_html
      journey_points = @journey_points
      relation = @relation
      html = ERB.new(File.read('./views/journey.html.erb')).result(binding)
      File.open("./html/journey-#{@relation.osm_id}.html", 'wb'){|f| f.write html}
    end
    
    def to_gpx
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.gpx do
          xml.trk do
            xml.name "Relation#{@relation.osm_id}"
            xml.trkseg do
              @journey_points.select{|s| s.class == Vertex}.each do |vertex|
                xml.trkpt :lat => vertex.lat, :lon => vertex.lon
              end
            end
          end
        end
      end
      
      gpx = builder.to_xml
      File.open("./html/journey-#{@relation.osm_id}.gpx", 'wb'){|f| f.write gpx}
      $logger.info "Journey: gpx published"
      gpx
    end
    
    private
    
    def populate_vertices_and_edges
      $logger.debug "Journey: populating from relation with #{@relation.ways.size} ways"
      @relation.ways.each do |way|
        $logger.debug "populating from way (#{way.nodes.size} nodes)"
        # TODO refactor to use lisp's first/second/rest approach
        way.nodes.each_with_index do |_, i|
          next if i == (way.nodes.size - 1)
          n1 = way.nodes[i]
          v1 = create_or_find_vertex n1
          n2 = way.nodes[i+1]
          v2 = create_or_find_vertex n2
          create_or_find_edge v1, v2
        end
      end
      
      $logger.debug "populating vertices and nodes from interconnection_pairs_of_nodes"
      
      @relation.interconnection_pairs_of_nodes.each do |n1, n2|
        v1 = create_or_find_vertex n1
        v2 = create_or_find_vertex n2
        create_or_find_edge v1, v2
      end
      
      @vertices.select!{|v| v.edges.size > 0}
      @vertices.each {|v| v.sort_edges_clockwise!}
      
      $logger.info "Journey loaded from relation #{@vertices.size} vertices and #{@edges.size} edges"
      @vertices.each {|v| $logger.debug v}
    end
    
    def create_or_find_vertex node
      raise "create_or_find_vertex: node cannot be nil" if node.nil?
      v = @vertices.find{|v| v.lat == node.lat && v.lon == node.lon}
      if v.nil?
        v = Vertex.new node.lat, node.lon
        @vertices << v
      end
      
      v
    end
    
    def create_or_find_edge v1, v2
      return nil if v1 == v2
      e = @edges.find{|e| e.include?(v1, v2)}
      if e.nil?
        e = Edge.new v1, v2
        @edges << e
      end
      
      return e
    end
    
    def travel_to vertex, edge_we_arrived_from
      if(edge_we_arrived_from) # nil if we just begin our trail
        edge_we_arrived_from.visits += 1
      end
      
      vertex.visits += 1
      @journey_points << vertex
      $logger.info "adding vertex #{vertex} to @journey_points"
      
      if (@vertices - @journey_points.select{|x| x.class == Osm::Vertex}.uniq) == []
        $logger.info "journey finished (all vertices travelled)"
        return
      end
      
      next_vertex, edge_we_will_travel_next = determine_next_hop vertex, edge_we_arrived_from
      if next_vertex
        travel_to next_vertex, edge_we_will_travel_next
      else
        $logger.info "journey finished"
      end
    end
    
    def determine_next_hop vertex, edge_we_arrived_from
      if edge_we_arrived_from.nil? # special case (initial vertex)
        edge_we_will_travel_next = vertex.edges.first
        $logger.debug "determine_next_hop: edge_we_will_travel_next: #{edge_we_will_travel_next}"
      else
        edge_we_will_travel_next = vertex.get_clockwise_edge_suitable_for_visit(edge_we_arrived_from)
      end
      
      if edge_we_will_travel_next.nil? # end of journey
        return [nil, nil]
      else
        next_vertex = edge_we_will_travel_next.complementary_vertex(vertex)
        [next_vertex, edge_we_will_travel_next]
      end
    end
  end
end