module CensusApi
  class Client
    attr_reader :api_key, :options, :dataset

    DATASETS = %w( sf1 acs5 ) # can add more datasets as support becomes available

    def initialize(api_key, options = {})
      raise ArgumentError, "You must set an api_key." unless api_key
      raise ArgumentError, "#{api_key} is not a valid API key." if invalid_api_key(api_key)

      @api_key = api_key
      if options[:dataset]
        raise ArgumentError, "#{options[:dataset]} is not a valid dataset" unless DATASETS.include? options[:dataset].downcase
        @dataset = options[:dataset].downcase
      end
    end

    def invalid_api_key(key)
      # Use RestClient directly to determine the validity of the API Key
      path = "http://api.census.gov/data/2010/sf1?key=#{api_key}&get=P0010001&for=state:01"
      response = RestClient.get(path)

      return response.body.include? "Invalid Key"
    end

    def dataset=(dataset)
      @dataset = dataset.downcase
    end

    def find(args)
      raise "Client has not been assigned a dataset to query. Try @client.dataset = 'SF1' or anything from #{DATASETS}" if self.dataset.nil?
      fields = args[:fields]
      of     = args[:of]
      within = args[:within]

      Request.find( dataset: @dataset,
                    api_key: @api_key,
                    fields:  fields,
                    of:      of,
                    within:  within )
    end

  end
end
