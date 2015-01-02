module Osm
  class Relation
    attr_accessor :osm_id, :ways, :interconnection_pairs_of_nodes
    def initialize osm_id
      @osm_id = osm_id
      @ways = []
      @interconnection_pairs_of_nodes = [] 
      $logger.info "Relation #{@osm_id}: initialized"
    end
    
    def load_from_osm_db
      url = "http://www.openstreetmap.org/api/0.6/relation/#{@osm_id}"
      $logger.info "Relation #{@osm_id}: downloading data from #{url}"
      relation_xml = open(url).read
      
      
      way_ids = extract_way_ids relation_xml
      $logger.info "Relation #{@osm_id}: extracted way ids: #{way_ids}"
      way_ids.each do |way_id|
        w = Way.new(way_id)
        @ways << w
        w.load_from_osm_db
      end
      
    end
    
    def save path_to_file
      File.open(path_to_file, 'wb'){ |f| f.write Marshal.dump(self) }
    end
    
    def to_s
      out = ["Relation #{@osm_id}: #{@ways.size} ways"]
      @ways.each {|w| out << w.to_s}
      out.join("\n")
    end
    
    def interconnect_ways distance_threshold_in_metres = 10.0
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
      html = ERB.new(File.read('./views/relation.html.erb')).result(binding)
      File.open("./html/relation-#{@osm_id}.html", 'wb'){|f| f.write html}
    end
    
    private
    def extract_way_ids relation_xml
      relation_hash = Hash.from_xml relation_xml
      ways = relation_hash['osm']['relation']['member']
      ways = [ways] if ways.class == Hash
      way_ids = []
      ways.each do |way|
        if way['type'] == 'way'
          way_id = way['ref'].to_i
          way_ids << way_id
        end
      end
      
      return way_ids
    end  
  end
end