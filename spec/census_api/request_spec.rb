require 'spec_helper'

describe CensusApi::Request do

  describe "#find one field" do

    context "with API syntax" do
      describe "with numerical arguments" do

        context "with wildcard level" do
          describe "with no within" do
            VCR.use_cassette "api_num_wildcard_no_within" do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'STATE')
              response.size.should == 52
              response.first.should == {"P0010001"=>"4779736", "name"=>"Alabama", "state"=>"01"}
            end
          end
          describe "with one within" do
            VCR.use_cassette "api_num_wildcard_one_within" do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'COUNTY', 'STATE:01')
              response.size.should == 67
              response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"} 
            end
          end
          describe "with multiple within arguments" do
            VCR.use_cassette "api_num_wildcard_multi_arg_within" do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'COUNTY', 'STATE:01,02')
              response.size.should == 67
            end
          end
          describe "with multiple within geographies" do
            VCR.use_cassette "api_num_wildcard_multi_geo_within" do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'COUSUB', 'STATE:01+COUNTY:003')
              response.size.should == 8
              response.first.should == {"P0010001"=>"23604", "name"=>"Bay Minette CCD", "state"=>"01", "county"=>"003", "county subdivision"=>"90207"}
            end
          end
        end

        context "with one specified level" do
          1.should == 1
        end
      end
    end

    # context "with Hash syntax" do
      
    #   describe "with numerical arguments" do
    #     before do
    #     end

    #     context "with wildcard level" do
    #       describe "with no within" do
    #         describe "singular" do
    #           pending ":county"
    #         end
    #         describe "plural" do
    #           pending ":counties"
    #         end
    #       end
    #       describe "with one within" do
    #         describe "singular" do
    #           pending ":county, state: 01"
    #         end
    #         describe "plural" do
    #           pending ":counties"
    #         end
    #       end
    #       describe "with multiple withins" do
    #         describe "singular" do
    #           pending ":county, states: 01,02"  
    #         end
    #         describe "plural" do
    #           pending ":counties, states: 01,02"  
    #         end
    #       end
    #     end

    #     context "with one specified level" do
    #       describe "with no within" do
    #         pending "county: 1"
    #       end
    #       describe "with one within" do
    #         pending "county: 1, state:1"
    #       end
    #       describe "with multiple withins" do
    #         pending "county: 1, state: 01,02"
    #       end
    #     end
    #   end

    #   describe "with text arguments" do
    #     pending "write these when numerical is ready, copy & paste & change params"
    #   end
    # end
  end
end