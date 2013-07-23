module CensusApi
  class Converter

    attr_reader :georef

    def initialize
      @georef = YAML.load(File.read('lib/yml/state_county.yml'))
    end


    def translate_names_to_nums(parameters)
      num_params = {}
      
      # Better way to do this: collect singularized keys
      parameters.each_pair do |key, value|
        key = key.to_s.singularize.downcase.to_sym
        val = nil
        
        # TODO: Metaprogram so key is part of method call
        if key == :state
          val = find_state_ids(value) if value.kind_of? Array
          val = find_state_id(value)  if value.kind_of? String
        elsif key == :county
          val = find_county_ids(value, parameters[:state]) if value.kind_of? Array
          val = find_county_id(value,  parameters[:state]) if value.kind_of? String
        end
        num_params.merge!(Hash[key, val])
      end

      return num_params
    end



    def find_state(param)
      state = @georef.select{ |state| state['abbr'] == param }.first if param.length == 2
      state = @georef.select{ |state| state['name'] == param }.first if param.length > 2
      return state
    end

    def find_county(county, state)
      state = find_state(state)
      return state['counties'].select{ |c| c['name'] == county }.first
    end

    def find_counties(counties, state)
      unless counties.kind_of? Array
        raise ArgumentError, "Request#find_counties takes an array of county names."
      end
    end

    def find_state_id(state)
      return find_state(state)['id'].to_i
    end

    def find_state_ids(states)
      unless states.kind_of? Array
        raise ArgumentError, "Request#find_counties takes an array of county names."
      end
      return states.collect{ |state| find_state_id(state) }
    end

    def find_county_id(county, state)
      return find_county(county, state)['id'].to_i
    end

    def find_counties(counties, state)
      return find_state(state)['counties'].select{|e| counties.include?(e['name'])}
    end

    def find_county_ids(counties, state)
      return find_counties(counties, state).collect{|e| e['id'].to_i}
    end

    def get_counties_from_state(state)
      return find_state(state)['counties']
    end

  end
end