module CensusApi
  class Converter

    attr_reader :georef

    def initialize
      @georef = YAML.load(File.read('lib/yml/state_county.yml'))
      return nil
    end

    def find_state(param)
      state = @georef.select{ |state| state['abbr'] == param }.first if param.length == 2
      state = @georef.select{ |state| state['name'] == param }.first if param.length > 2
      return state
    end

    def find_id(state)
      find_state(state)['id'].to_i
    end

    def find_county_in_state(county, state)
      state = find_state(state)
      county = state['counties'].select{ |c| c['name'] == county }.first
      return county['id'].to_i, state['id'].to_i
    end

    def find_counties_in_state(counties, state)
      county_ids = find_state(state)['counties'].select{|e| counties.include?(e['name'])}.collect{|e| e['id'].to_i}
      return county_ids, find_id(state)
    end

    def get_counties_from_state(state)
      find_state(state)['counties']
    end

  end
end