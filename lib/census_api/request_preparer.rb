module CensusApi
  class RequestPreparer

    @converter = CensusApi::Converter.new

    def self.prepare_request(of, within)

      # FUCK. Singularize and downcase then store of, within keys
      # Merge into geopath, do the SHIT.
      # Split back into of and within hases based on stored keys
      # Because you need to pass the api of and within
      of_key     = of.format_keys.first.first
      within_key = within.format_keys.first.first

      puts "of: #{of_key}, within: #{within_key}"

      geopath = of.merge(within)

      if geopath.keys.include? :county and geopath.keys.include? :state
        puts "both found"
        county = geopath[:county]
        state  = geopath[:state]
        geopath[:county] = @converter.county_id(county, state)
        geopath[:state]  = @converter.state_id(state)
        
      elsif geopath.keys.include? :county
        puts "county found"
        county = geopath[:county]
        geopath[:county] = @converter.county_id(county)
        
      elsif geopath.keys.include? :state
        puts "state found"
        state = geopath[:state]
        geopath[:state] = @converter.state_id(state)
      end

      of = geopath[of_key]
      within = geopath[within_key]
      return {of: Hash[of_key, of], within: Hash[within_key, within]}
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
        puts result.inspect
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