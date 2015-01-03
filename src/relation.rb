module Osm
  class Relation
    @@erb_view = File.read('./views/relation.html.erb')
    
    attr_accessor :osm_id, :ways, :interconnection_pairs_of_nodes
    def initialize osm_id
      @osm_id = osm_id
      @ways = []
      @interconnection_pairs_of_nodes = [] 
      $logger.info "Relation #{@osm_id}: initialized"
    end
    
    def load
      xml_filename = "relations.dump/relation-#{@osm_id}.xml"
      
      if File.exists?(xml_filename)
        $logger.info "Relation #{@osm_id}: loading from #{xml_filename}"
        relation_xml = File.read xml_filename
      else
        url = "http://www.openstreetmap.org/api/0.6/relation/#{@osm_id}/full"
        $logger.info "Relation #{@osm_id}: downloading data from #{url}"
        relation_xml = open(url).read
        File.open(xml_filename, 'wb'){|f| f.write relation_xml}
      end

      h = Hash.from_xml relation_xml
      
      h_nodes = h['osm']['node']
      h_nodes = [h_nodes] if h_nodes == Hash
      node_osm_id_to_latlon = {}
      h_nodes.each do |h_node|
        node_osm_id = h_node['id']
        lat = h_node['lat']
        lon = h_node['lon']
        
        node_osm_id_to_latlon[node_osm_id] = [lat, lon]
      end
      
      h_ways = h['osm']['way']
      h_ways = [h_ways] if h_ways.class == Hash
      h_ways.each do |h_way|
        way_osm_id = h_way['id']
        w = Way.new(way_osm_id)
        h_way['nd'] = [h_way['nd']] if h_way['nd'].class == Hash
        way_node_ids = h_way['nd'].collect{|hn| hn['ref']}
        way_node_ids.each do |node_osm_id|
          lat, lon = node_osm_id_to_latlon[node_osm_id]
          w.nodes << Node.new(node_osm_id, w, lat, lon)
        end
        
        @ways << w
      end
      
    end
    
    def to_s
      out = ["Relation #{@osm_id}: #{@ways.size} ways"]
      @ways.each {|w| out << w.to_s}
      out.join("\n")
    end
    
    def determine_interconnections distance_threshold_in_metres = 10.0
      $logger.info "Relation #{@osm_id}: Interconnecting ways"
      end_nodes = @ways.collect(&:end_nodes).flatten
      
      @interconnection_pairs_of_nodes = []
      
      end_nodes.each_with_index do |node1, i|
        end_nodes.each_with_index do |node2, j|
          if i < j && !node1.belongs_to_the_same_way_as?(node2)
            distance_m = node1.distance_to_node_in_metres(node2)
            if distance_m < distance_threshold_in_metres
              @interconnection_pairs_of_nodes << [node1, node2]
            end
          end
        end
      end
    end
    
    def to_html
      relation = self
      html = ERB.new(@@erb_view).result(binding)
      html_file = "relation-#{@osm_id}.html"
      File.open("./html/#{html_file}", 'wb'){|f| f.write html}
      
      html_file
    end
  end
end