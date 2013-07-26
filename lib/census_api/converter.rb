module CensusApi
  class Converter

    # There's a flock of ducks in here somewhere.

    attr_reader :georef

    def initialize
      @georef = YAML.load(File.read('lib/yml/state_county.yml'))
    end


    def county_id(county, state)
      puts "county class: #{county.class}"
      return find_county_ids(county, state) if county.kind_of? Array
      return find_county_id(county, state)  if (county.kind_of? Fixnum or county.kind_of? String)
    end

    def state_id(state)
      puts "state class: #{state.class}"
      return find_state_ids(state) if state.kind_of? Array
      return find_state_id(state)  if (state.kind_of? Fixnum or state.kind_of? String)
    end



    def find_state(param)
      state = @georef.select{ |state| state['id']   == "%02d" % param }.first if param.kind_of? Fixnum
      state = @georef.select{ |state| state['abbr'] == param }.first if (param.kind_of? String and param.length == 2)
      state = @georef.select{ |state| state['name'] == param }.first if (param.kind_of? String and param.length >  2)
      return state
    end

    def find_county(county, state)
      state  = find_state(state)
      county = state['counties'].select{ |c| c['id']   == "%03d" % county }.first if county.length <= 3
      county = state['counties'].select{ |c| c['name'] == county }.first if county.length > 3
      return county
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
      counties = counties.collect{|c| ("%03d" % c if c.kind_of? Fixnum) || c }
      counties_in_state = find_state(state)['counties']
      return counties_in_state.select{|county| counties.include?(county['name']) || counties.include?(county['id']) }
    end

    def find_county_ids(counties, state)
      return find_counties(counties, state).collect{|e| e['id'].to_i}
    end

    def get_counties_from_state(state)
      return find_state(state)['counties']
    end



  end
end