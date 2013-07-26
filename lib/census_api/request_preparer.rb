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


    def self.format_request(api_key, fields, params)
      # TODO: This is going to be super-f'd
      params = { :key => api_key, :get => fields, :for => format(of, false) }
      params.merge!({ :in => format(within, true) }) unless within.nil?
    end

    protected
  
      def self.format(str,truncate)
        result = str.split("+").map do |s|
          if s.match(":")
            s = s.split(":")
          else 
            s = [s,"*"]
          end
          shp = shapes[s[0].upcase]
          s.shift && s.unshift(shp['name'].downcase.gsub(" ", "+")) if !shp.nil?
          s.unshift(s.shift.split("/")[0]) if !s[0].scan("home+land").empty? && truncate
          s.join(":")
        end
        return result.join("+")
      end

      def self.shapes
        return @@census_shapes if defined?( @@census_shapes )
        @@census_shapes = {}
        YAML.load_file( File.dirname(__FILE__).to_s + '/../yml/census_shapes.yml' ).each{ |k,v| @@census_shapes[k] = v }
        return @@census_shapes
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

  def to_params
    self.map { |k,v| "#{k}=#{v}" }.join("&")
  end

end