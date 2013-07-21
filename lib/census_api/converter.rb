module CensusApi
  class Converter

    attr_reader :georef

    def initialize
      @georef = YAML.load(File.read('lib/yml/state_county.yml'))
    end

    def find_id(param)
      state = @georef.select{ |entry| entry['abbr'] == param }.first if param.length == 2
      state = @georef.select{ |entry| entry['name'] == param }.first if param.length > 2
      return state['id']
    end

  end
end