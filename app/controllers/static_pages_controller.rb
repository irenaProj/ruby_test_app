class StaticPagesController < ApplicationController
  require 'multi_json'
  require 'httparty'
  
  def home
    #curl -g -k -u 72db99d0-05dc-0133-cefe-22000a93862b:_cIOpimIoDi3RIviWteOTA -H "Accept: application/json" "https://api-impac-uat.maestrano.io/api/v1/get_widget?engine=hr/employees_list&metadata[organization_ids][]=org-fbte"
    
    params = MultiJson.load('{"engine":"hr/employees_list", "metadata[organization_ids][]": "org-fbte"}')
    auth = {username: "72db99d0-05dc-0133-cefe-22000a93862b", password: "_cIOpimIoDi3RIviWteOTA"}
    options = {query: params, basic_auth: auth}
    
    @content = HTTParty.get("http://api-impac-uat.maestrano.io/api/v1/get_widget", 
                    options)
  end

  def help
  end
end

    # #curl -g -k -u 72db99d0-05dc-0133-cefe-22000a93862b:_cIOpimIoDi3RIviWteOTA -H "Accept: application/json" "https://api-impac-uat.maestrano.io/api/v1/get_widget?engine=hr/employees_list&metadata[organization_ids][]=org-fbte"
    
    # #params = MultiJson.load('{"engine":"hr/employees_list", "metadata[organization_ids][]": "org-fbte"}')

    # auth = {username: "72db99d0-05dc-0133-cefe-22000a93862b", password: "_cIOpimIoDi3RIviWteOTA"}
    # #options = {query: params, basic_auth: auth}
    
    # @content = HTTParty.get("http://api-impac-uat.maestrano.io/api/v1/get_widget?engine=hr/employees_list&metadata[organization_ids][]=org-fbte", 
    #                 {basic_auth: auth})

    # #@content = MultiJson.load('{"abc":"def"}') #=> {"abc" => "def"}
