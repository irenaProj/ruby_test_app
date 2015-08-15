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
        params = MultiJson.load('{"engine":"invoices/list", "metadata[organization_ids][]": "org-fbte", "metadata[entity]": "customers|suppliers"}')
      else
         raise StandardError
      end      
      
      auth = {username: "72db99d0-05dc-0133-cefe-22000a93862b", password: "_cIOpimIoDi3RIviWteOTA"}
      options = {query: params, basic_auth: auth}
      
      @content = HTTParty.get("http://api-impac-uat.maestrano.io/api/v1/get_widget", options)
    end  
  end  

  # Prepare data to be displayed on "Employees location" widget - acquire raw data and process as following:
  # data received from hr/employees_list and hr/employee_details is almost identical, locations can be 
  # deducted based on employees_list only. In addition, "work_locations" key of some employees is empty and,
  # where exists - it specifies the location via ID only, thus, for the sake of the exercise, widget will 
  # be based on address field instead.
  # In addition, for this exercise, location is determined by city and country, e.g 'San Francisco CA 94123, United States'
  def employeeLocationWidgetPrepare()
    locations = Hash.new
    
    employeesList = (RawData.new("employee_details").getMnoData())['content']['employees']
    employeesList.each do | employee |
      # extract the city/country information from the 'address' field
      location = employee['address'].split(/\s*[,;]\s*/x).from(-2).join(', ')
      #puts location
      
      # Update quantity in Hash
      occurrence = locations.fetch(location, -1)
      
      if occurrence > 0
        locations[location] += 1
      else
         locations[location] = 1
      end    
      
      #puts locations
    end
    
    return locations
  end  
  
  # Prepare data to be displayed on "Sales flow" widget - acquire raw data and process as following:
  # Retrieve data via Impac! API, 
  def salesFlowWidgetPrepare()
    locations = Hash.new
    
    employeesList = (RawData.new("employee_details").getMnoData())['content']['employees']
    employeesList.each do | employee |
      # extract the city/country information from the 'address' field
      location = employee['address'].split(/\s*[,;]\s*/x).from(-2).join(', ')
      #puts location
      
      # Update quantity in Hash
      occurrence = locations.fetch(location, -1)
      
      if occurrence > 0
        locations[location] += 1
      else
         locations[location] = 1
      end    
      
      #puts locations
    end
    
    return locations
  end  

  def home
    @locationsData = employeeLocationWidgetPrepare()
    puts @locationsData
    
    rawData = RawData.new("employee_details")
    @employeeDetails = rawData.getMnoData()

    rawData = RawData.new("invoices")
    @invoices = rawData.getMnoData()

  end

  def help
  end
end
