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

    def initialize(dataset, params)
      @response = RestClient.get("#{CENSUS_URL}/#{dataset}?#{options.to_params}")
      return @response
    end


    def self.find(args)
      dataset = args[:dataset]
      api_key = args[:api_key]
      fields  = args[:fields]
      of      = args[:of]
      within  = args[:within]

      params = RequestPreparer.prepare_request(of, within)
      params = RequestPreparer.format_request(api_key, fields, params)

      params = { :key => api_key, :get => fields, :for => format(of, false) }
      params.merge!({ :in => format(within, true) }) unless within.nil?

      return new(dataset, params).parse_response
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
        @converter = CensusApi::Converter.new
        puts "before #{options}"
        options = @converter.translate_names_to_nums(options)
        puts "after convert #{options}"
        options = hash_to_census_string(options)
        puts "after hash #{options}"
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
