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
      @response = RestClient.get("#{CENSUS_URL}/#{dataset}?#{params}")
      return @response
    end



    def self.find(args)
      dataset = args[:dataset]
      api_key = args[:api_key]
      fields  = args[:fields]
      of      = args[:of]
      within  = args[:within]

      of, within = RequestPreparer.prepare_request(of, within)
      # TODO: the line below should be private to RequestPreparer
      # but we're keeping it here for now because, refactoring
      params     = RequestPreparer.format_request(api_key, fields, of, within)

      return new(dataset, params).parse_response
    end



    def parse_response
      case @response.code
      when 200
        response = JSON.parse(@response)
        header = response.delete_at(0)
        return response.map{ |r| Hash[header.map{|h| h.gsub("NAME","name")}.zip(r)] }
      else
        return {:code => @response.code, 
                :message=> "Error: invalid request",
                :location=> @response.headers[:location],
                :body => @response.body}
      end
    end

  end
end