require 'spec_helper'

describe CensusApi::Client do

  describe "client initialization" do

    it 'should not initialize without an api_key' do
      lambda { CensusApi::Client.new }.should raise_error
    end

    it 'should initialize with an api_key' do
      VCR.use_cassette 'initialize_client' do
        @client = CensusApi::Client.new(api_key)
        @client.api_key.should == api_key
      end
    end
  end

  describe "client and dataset initialization" do

    it 'should initialize with an api_key and dataset' do
      VCR.use_cassette 'initialize_client_and_dataset' do
        dataset = 'SF1'
        @client = CensusApi::Client.new(api_key, dataset: dataset)
        @client.api_key.should == api_key
        @client.dataset.should == dataset.downcase
      end
    end

    it 'should request sf1' do
      VCR.use_cassette 'initialize_client_and_dataset' do
        source, options = 'sf1', {:key=> api_key, :fields => 'P0010001', :level => 'STATE:06', :within=>{:within=>[]}}
        @client = CensusApi::Client.new(api_key, dataset: source)
        CensusApi::Request.should_receive(:find).with(@client.dataset, options[:key], options[:fields], options[:level], options[:within])
        @client.find(options[:fields], options[:level])
      end
    end

    it 'should request acs5' do
      VCR.use_cassette 'initialize_client_and_dataset' do
        source, options = 'acs5', {:key=> api_key, :fields => 'B00001_001E', :level => 'STATE:06', :within=>{:within=>[]}}
        @client = CensusApi::Client.new(api_key, dataset: source)
        CensusApi::Request.should_receive(:find).with(@client.dataset, options[:key], options[:fields], options[:level], options[:within])
        @client.find(options[:fields], options[:level])
      end
    end
  end
end