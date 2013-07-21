require 'spec_helper'


describe CensusApi::Converter do

  before { @converter = CensusApi::Converter.new }

  it "loads the georeference YAML file" do
    @converter.georef.first.first == ["name", "Alabama"]
  end

  it "converts a state full name to FIPS" do
    id = @converter.find_id('Massachusetts')
    id.should == 25
  end

  it "converts a state abbreviation to FIPS" do
    id = @converter.find_id('MA')
    id.should == 25
  end

  it "converts another state full name to FIPS" do
    id = @converter.find_id('Rhode Island')
    id.should == 44
  end

  describe "with multiple state names" do
    it "should return an id" do
      states = [
        {name: 'Massachusetts', id: 25},
        {name: 'Rhode Island',  id: 44},
        {name: 'California',    id: 6},
        {name: 'Puerto Rico',   id: 72}
      ]
      states.each do |state|
        @converter.find_id(state[:name]).should == state[:id]
      end
    end
  end

  describe "with multiple state abbrevations" do
    it "should return an id" do
      states = [
        {abbr: 'MA', id: 25},
        {abbr: 'RI', id: 44},
        {abbr: 'CA', id: 6},
        {abbr: 'PR', id: 72}
      ]
      states.each do |state|
        @converter.find_id(state[:abbr]).should == state[:id]
      end
    end
  end


  describe "with nested geography" do
    it "returns a state and county id given both in text" do
      county, state = @converter.find_nested_ids('Worcester County', 'MA')
      county.should == 27
      state.should  == 25
    end
  end



end