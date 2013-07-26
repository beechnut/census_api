module CensusApi
  class RequestPreparer

    @converter = CensusApi::Converter.new



    def self.prepare_request(of, within=nil)

      puts "RequestPreparer#prepare_request"
      puts "within is #{within.inspect}"

      of     = of.format_keys
      within = within.format_keys    if within

      of_key     = of.keys.first
      within_key = within.keys.first if within

      geopath = of
      geopath = of.merge(within)     if within

      if geopath.keys.include? :county and geopath.keys.include? :state
        puts "both found"
        county           = geopath[:county]
        state            = geopath[:state]
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
      within = geopath[within_key] if within

      return_values = [Hash[of_key, of], nil]
      return_values = return_values.compact << Hash[within_key, within] if within
      puts "prepare_request return values: #{return_values.inspect}"
      return return_values
    end



    def self.format_request(api_key, fields, of, within)
      puts "RequestPreparer#format_request"
      of     = self.make_convertible_string(of)
      within = self.make_convertible_string(within) if within
      # I feel like the above step is an unnecessary intermediary.

      params = { :key => api_key, :get => fields, :for => format(of, false) }
      params.merge!({ :in => format(within, true) }) unless within.nil?
      params = params.to_params
    end


    def self.cond_join(val)
      puts "RequestPreparer#cond_join"
      return val.join(',') if val.kind_of? Array
      val
    end


    def self.make_convertible_string(hash)
      puts "RequestPreparer#make_convertible_string"
      puts hash.inspect
      ret = "#{hash.keys.first.to_s}:#{self.cond_join(hash.values.first)}"
      puts ret.inspect
      puts "end RequestPreparer#make_convertible_string"
      return ret
    end


    protected
  
      def self.format(str,truncate)
        puts "RequestPreparer#format"
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