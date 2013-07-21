require 'spec_helper'

describe CensusApi::Request do

  describe "#find from each dataset" do
    pending "test each dataset, sf1 and acs5"
  end

  describe "#geometry with at least one of every sumlev" do
    pending "try COUSUB, SUBMCD, and all other geog/sumlev types"
  end

  describe "#find one field" do
    
    context "API syntax" do
      describe "numerical arguments" do

        context "wildcard level" do
          it "no within" do
            VCR.use_cassette "api_num_wildcard_no_within" do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'STATE')
              response.size.should == 52
              response.first.should == {"P0010001"=>"4779736", "name"=>"Alabama", "state"=>"01"}
            end
          end
          it "one within" do
            VCR.use_cassette "api_num_wildcard_one_within" do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'COUNTY', 'STATE:01')
              response.size.should == 67
              response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"} 
            end
          end
          # it "multiple within arguments" do
          #   VCR.use_cassette "api_num_wildcard_multi_arg_within" do
          #     response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'COUNTY', 'STATE:01,02')
          #     response.size.should be > 67
          #   end
          # end
          it "multiple within geographies" do
            VCR.use_cassette "api_num_wildcard_multi_geo_within" do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'COUSUB', 'STATE:01+COUNTY:003')
              response.size.should == 8
              response.first.should == {"P0010001"=>"23604", "name"=>"Bay Minette CCD", "state"=>"01", "county"=>"003", "county subdivision"=>"90207"}
            end
          end
        end

        context "one specified level" do
          it "no within" do
            VCR.use_cassette "api_num_onelevel_no_within" do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'STATE:01')
              response.size.should == 1
              response.first.should == {"P0010001"=>"4779736", "name"=>"Alabama", "state"=>"01"}
            end
          end
          it "one within" do
            VCR.use_cassette "api_num_onelevel_one_within" do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'COUNTY:001', 'STATE:01')
              response.size.should == 1
              response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"} 
            end
          end
          it "multiple within geographies" do
            VCR.use_cassette "api_num_onelevel_multi_geo_within" do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', 'COUSUB:90207', 'STATE:01+COUNTY:003')
              response.size.should == 1
              response.first.should == {"P0010001"=>"23604", "name"=>"Bay Minette CCD", "state"=>"01", "county"=>"003", "county subdivision"=>"90207"}
            end
          end
        end
      end
    end

    context "with Hash syntax" do
      describe "with numerical arguments" do
        context "with wildcard level" do

          describe "with no within" do
            it "singular" do
              VCR.use_cassette 'hash_num_wildcard_no_within_sing' do
                response = CensusApi::Request.find('sf1', api_key, 'P0010001', :county)
                response.size.should == 3221
                response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"} 
              end
            end
            it "plural" do
              VCR.use_cassette 'hash_num_wildcard_no_within_plural' do
                response = CensusApi::Request.find('sf1', api_key, 'P0010001', :counties)
                response.size.should == 3221
                response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"} 
              end
            end
          end

          describe "with one within" do
            it "singular" do
              VCR.use_cassette 'hash_num_wildcard_one_within_sing' do
                response = CensusApi::Request.find('sf1', api_key, 'P0010001', :county, state: 01)
                response.size.should == 67
                response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"}
              end
            end
            it "plural" do
              VCR.use_cassette 'hash_num_wildcard_one_within_plur' do
                response = CensusApi::Request.find('sf1', api_key, 'P0010001', :counties, state: 01)
                response.size.should == 67
                response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"}
              end
            end
          end

          # describe "with multiple withins" do
          #   it "singular" do
          #     VCR.use_cassette 'hash_num_wildcard_multi_within_sing' do
          #       response = CensusApi::Request.find('sf1', api_key, 'P0010001', :county, states: [01, 02])
          #       response.size.should be > 67
          #       response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"}
          #     end
          #   end
          #   it "plural" do
          #     VCR.use_cassette 'hash_num_wildcard_multi_within_mult' do
          #       response = CensusApi::Request.find('sf1', api_key, 'P0010001', :counties, states: [01, 02])
          #       response.size.should be > 67
          #       response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"}
          #     end
          #   end
          # end

        end

        context "with one specified level" do
          it "with no within" do
            VCR.use_cassette 'hash_num_onelevel_no_within_plur' do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', state: 1)
              response.size.should == 1
              response.first.should == {"P0010001"=>"4779736", "name"=>"Alabama", "state"=>"01"}
            end
          end
          it "with one within" do
            VCR.use_cassette 'hash_num_onelevel_one_within_plur' do
              response = CensusApi::Request.find('sf1', api_key, 'P0010001', {county: 1}, state: 1)
              response.size.should == 1
              response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"}
            end
          end
          # it "with multiple withins" do
          #   pending "county: 1, state: 01,02"
          # end
        end
      end

      context "with multiple levels specified" do
        it "with no within" do
          VCR.use_cassette 'hash_num_multilevel_no_within_plur' do
            response = CensusApi::Request.find('sf1', api_key, 'P0010001', state: [1,2])
            response.size.should  == 2
            response.first.should == {"P0010001"=>"4779736", "name"=>"Alabama", "state"=>"01"}
            response.last.should  == {"P0010001"=>"710231", "name"=>"Alaska", "state"=>"02"} 
          end
        end
        it "with one within" do
          VCR.use_cassette 'hash_num_multilevel_one_within_plur' do
            response = CensusApi::Request.find('sf1', api_key, 'P0010001', {county: [1,3]}, state: 1)
            response.size.should  == 2
            response.first.should == {"P0010001"=>"54571", "name"=>"Autauga County", "state"=>"01", "county"=>"001"}
            response.last.should  == {"P0010001"=>"182265", "name"=>"Baldwin County", "state"=>"01", "county"=>"003"}
          end
        end
      end

      describe "with text arguments" do
        pending "rewrite numerical arg tests with text args"
      end
    end
  end
end