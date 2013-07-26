module CensusApi
  class RequestPreparer

    @converter = CensusApi::Converter.new

    def self.prepare_request(of, within)

      geopath = of.merge(within).format_keys

      if geopath.keys.include? :county and geopath.keys.include? :state
        puts "both found"
        county = geopath[:county]
        state  = geopath[:state]
        geopath[:county] = @converter.county_id(county, state)
        geopath[:state]  = @converter.state_id(state)
        return geopath

      elsif geopath.keys.include? :county
        puts "county found"
        county = geopath[:county]
        geopath[:county] = @converter.county_id(county)
        return geopath

      elsif geopath.keys.include? :state
        puts "state found"
        state = geopath[:state]
        geopath[:state] = @converter.state_id(state)
        return geopath
      end

    end
  end
end



class Hash
  def downcase_keys
    key_ary = self.keys.collect { |key| key.to_s.downcase.to_sym }
    Hash[key_ary.zip(self.values)]
  end

  def singularize_keys
    key_ary = self.keys.collect { |key| key.to_s.singularize.to_sym }
    Hash[key_ary.zip(self.values)]
  end

  def format_keys
    key_ary = self.downcase_keys
    key_ary = key_ary.singularize_keys
  end

end