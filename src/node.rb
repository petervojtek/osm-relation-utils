class Numeric
  def to_rad
    self * Math::PI / 180
  end
end

module Osm
  class Node
    @@node_counter = 0
    
    attr_accessor :osm_id, :way, :lat, :lon, :simplified_id
    def initialize osm_id, way, lat, lon
      @osm_id = osm_id
      @lat = lat.to_f
      @lon = lon.to_f
      @way = way
      @simplified_id = @@node_counter
      @@node_counter += 1
      $logger.info "Node #{@osm_id}: initialized"
    end
    
    def belongs_to_the_same_way_as? another_node
      self.way.osm_id == another_node.way.osm_id
    end
    
    def to_s
      "    N#{@simplified_id} [OSM #{@osm_id}]: latitude:#{@lat}, longitude:#{@lon}, belongs to W#{@way.simplified_id} [OSM #{@way.osm_id}]"
    end
  
    # https://gist.github.com/j05h/673425
    def distance_to_node_in_metres another_node
      lat1, lon1 = @lat, @lon
      lat2, lon2 = another_node.lat, another_node.lon
      if (lat1 == lat2 && lon1 == lon2)
        return 0.0
      end
     
      dLat = (lat2-lat1).to_rad;
      dLon = (lon2-lon1).to_rad;
      a = Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(lat1.to_rad) * Math.cos(lat2.to_rad) *
      Math.sin(dLon/2) * Math.sin(dLon/2);
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
     
      return(6371.0 * c * 1000.0)
    end
  end

end