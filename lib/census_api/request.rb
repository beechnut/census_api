module CensusApi
  class Request
    
    require 'active_support/inflector'
    require 'restclient'
    require 'hpricot'
    require 'json'
    require 'yaml'
    
    attr_accessor :response
    
    @@census_shapes
    
    CENSUS_URL = "http://api.census.gov/data/2010"

    def initialize(url, source, options)
      @response = RestClient.get("#{url}/#{source}?#{options.to_params}")
      return @response
    end


    def self.find(source, api_key, fields, level, options={})
      fields  = format_field_params  fields
      level   = format_level_params  level
      options = format_option_params options

      params = { :key => api_key, :get => fields, :for => format(level, false) }
      params.merge!({ :in => format(options, true) }) unless options.nil?

      return new(CENSUS_URL, source, params).parse_response
    end
    

    def parse_response
      case @response.code
        when 200
          response = JSON.parse(@response)
          header = response.delete_at(0)
          return response.map{|r| Hash[header.map{|h| h.gsub("NAME","name")}.zip(r)]}
        else
          return {:code => @response.code, :message=> "Error: invalid request", :location=> @response.headers[:location], :body => @response.body}
        end
    end
    
    protected

      def self.format_option_params(options)
        return "" if options.empty?
        return options if options.kind_of? String
        options = hash_to_census_string(options)
      end

      def self.hash_to_census_string(hash)
        hash.collect do |option|
          option.join(':').upcase
        end.join('+')
      end

      def self.format_field_params(fields)
        fields = fields.split(",") if fields.kind_of? String
        fields = fields.push("NAME").join(",")
        return fields
      end

      def self.format_level_params(level)
        level = level.censify                 if level.kind_of? Hash
        level = level.to_s.singularize.upcase if level.kind_of? Symbol
        return level
      end
  
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
  def to_params
    self.map { |k,v| "#{k}=#{v}" }.join("&")
  end

  def censify
    key = self.keys.first.to_s.upcase
    key = key.singularize
    vals = self.values.first.kind_of?(Array) ? self.values.first.collect{|e| e.to_s}.join(',') : self.values.first
    "#{key}:#{vals}"
  end

end
