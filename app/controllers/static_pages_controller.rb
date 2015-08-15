class StaticPagesController < ApplicationController
  require 'multi_json'
  require 'httparty'
  
  # Class for retrieving data using Impac! API
  class RawData  
    # dataType - specifies the data to retrieve
    def initialize(dataType)  
      # Instance variables  
      @dataType = dataType  
    end  
    
    # Read raw data per provided type
    def getMnoData  
      #curl -g -k -u 72db99d0-05dc-0133-cefe-22000a93862b:_cIOpimIoDi3RIviWteOTA -H "Accept: application/json" "https://api-impac-uat.maestrano.io/api/v1/get_widget?engine=hr/employees_list&metadata[organization_ids][]=org-fbte"
      
      if @dataType == 'employees_list'
        params = MultiJson.load('{"engine":"hr/employees_list", "metadata[organization_ids][]": "org-fbte"}')
      elsif @dataType == 'employee_details'
        params = MultiJson.load('{"engine":"hr/employee_details", "metadata[organization_ids][]": "org-fbte"}')
      elsif @dataType == 'invoices'
        params = MultiJson.load('{"engine":"invoices/list", "metadata[organization_ids][]": "org-fbte"}')
      else
         raise StandardError
      end      
      
      auth = {username: "72db99d0-05dc-0133-cefe-22000a93862b", password: "_cIOpimIoDi3RIviWteOTA"}
      options = {query: params, basic_auth: auth}
      
      @content = HTTParty.get("http://api-impac-uat.maestrano.io/api/v1/get_widget", options)
    end  
  end  

  # Prepare data to be displayed on "Employees location" widget - acquire raw data and process
  def employeeLocationWidgetPrepare(dataType)
    rawData = RawData.new(dataType)
    @data = rawData.getMnoData()
  end  
  
  
  def home
    @employeesList = employeeLocationWidgetPrepare("employees_list")
    
    rawData = RawData.new("employee_details")
    @employeeDetails = rawData.getMnoData()

    rawData = RawData.new("invoices")
    @invoices = rawData.getMnoData()

  end

  def help
  end
end
