class StaticPagesController < ApplicationController
  require 'multi_json'
  require 'httparty'
  require 'geocoder'
  
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
  def employeeLocationWidgetPrepare()
    locations = Hash.new
    
    employeesList = (RawData.new("employee_details").getMnoData())['content']['employees']
    employeesList.each do | employee |
      # extract the city/country information from the 'address' field
      address = employee['address']
      location = employee['address'].gsub(/\ \d+/, "")
      location =location.split(/\s*[,;]\s*/x).from(-2).join(', ')
      
      # Update quantity in Hash
      occurrence = locations.fetch(location, nil)
      
      if !occurrence
         locations[location] = Array.new
      end    
      
      locations[location].push(address)
      
      #puts locations
    end

    return locations
  end  
  
  # Prepare data to be displayed on "Employees location" widget - acquire raw data and process as following:
  # data received from hr/employees_list and hr/employee_details is almost identical, locations can be 
  # deducted based on employees_list only. In addition, "work_locations" key of some employees is empty and,
  # where exists - it specifies the location via ID only, thus, for the sake of the exercise, widget will 
  # be based on address field instead.
  def employeeLocationWidgetPrepare()
    locations = Hash.new
    
    employeesList = (RawData.new("employee_details").getMnoData())['content']['employees']
    employeesList.each do | employee |
      # extract the city/country information from the 'address' field
      address = employee['address']
      location = employee['address'].gsub(/\ \d+/, "")
      location = location.split(/\s*[,;]\s*/x).from(-2).join(', ')
      
      # Add to locations records
      occurrence = locations.fetch(location, nil)
      
      if !occurrence
         locations[location] = Array.new
      end    
      
      locations[location].push(address)
      
      #puts locations
    end

    return locations
  end  
  
  # Prepare data to be displayed on "Sales flow" widget - acquire raw data and process as following:
  # Retrieve data via Impac! API, where "address" field contains enough data to allow geolocation,
  # add address and the invoice data to the records 
  def salesFlowWidgetPrepare()
    # Opacity set for the marker with lowest total
    min_opacity = 0.25 
    
    # Maximal opacity (1) - min_opacity (0.25)
    opacity_range = 0.75

    markers = Hash.new
    invoicesData = Hash.new
    minAmount = 1152921504606846976 # 2^60
    maxAmount = -1
    recNum = 0
    
    invoicesData["center"] = { 'lat'=> 35.864716, 'lng'=> 2.349014, 'zoom'=> 1  }
    
    invoicesList = (RawData.new("invoices").getMnoData())['content']['entities']
    
    invoicesList.each { | invoice |
      # First, extract 'address' field and check if contains enough details to identify on a map
      addrRaw = invoice['address']
      location =  (addrRaw['s']  == "-") ? "" : "#{addrRaw['s']}, "
      location += (addrRaw['s2'] == "-") ? "" : "#{addrRaw['s2']}," 
      location += (addrRaw['l']  == "-") ? "" : "#{addrRaw['l']}, " 
      location += (addrRaw['r']  == "-") ? "" : "#{addrRaw['r']}, " 
      location += (addrRaw['z']  == "-") ? "" : "#{addrRaw['z']}, " 
      location += (addrRaw['c']  == "-") ? "" : "#{addrRaw['c']}"
      
      result = Geocoder.search(location) 
      
      # If no results are returned or multiple results (ambigues), skip this record
      if result.length == 1
        recNum += 1
  
        # Fill information about this location (company) to be displayed on a map
        # Opacity is set to 1 by default, will be changed in the second pass if required
        marker = Hash.new    
        totalInvoiced = invoice['total_invoiced']
        
        marker['lat'] = result[0].latitude
        marker['lng'] = result[0].longitude
        marker['message'] = "#{invoice['name']}, total invoiced: $#{totalInvoiced} USD" 
        marker['focus'] = false
        marker['opacity'] = 1
        marker['total'] = totalInvoiced
        
        # Check for min/max
        if totalInvoiced > maxAmount
          maxAmount = totalInvoiced
        end

        if totalInvoiced < minAmount
          minAmount = totalInvoiced
        end
        
        markers["marker#{recNum}"] = marker
      end    
    }

    puts "33333333"
    puts minAmount
    puts maxAmount
      
    # Opacity range [0.25, 1], invoices range [minAmount, maxAmount],
    # calculate opacity for each marker 
    if maxAmount > minAmount
      markers.each do | record, value |
        markerTotal = value['total']
        puts markerTotal
        value['opacity'] = min_opacity + ((( markerTotal - minAmount) / ( maxAmount - minAmount )) * opacity_range)
        value.delete 'total'
        puts value
      end
    end
    
    puts "4444444"
    puts markers
    
    # Add baselayers
    invoicesData['layers'] = Hash.new
    
    # Add baselayers
    invoicesData['layers']['baselayers'] = {
      'mapbox_light' => {
        'name' => 'Mapbox Light',
        'url' => 'http://api.tiles.mapbox.com/v4/{mapid}/{z}/{x}/{y}.png?access_token={apikey}',
        'type' => 'xyz',
        'layerOptions' => {
          'apikey' => 'pk.eyJ1IjoiYnVmYW51dm9scyIsImEiOiJLSURpX0pnIn0.2_9NrLz1U9bpwMQBhVk97Q',
          'mapid' => 'bufanuvols.lia22g09'
        }
      }
    }
    
    invoicesData['markers'] = markers
    
    return invoicesData
  end  
  
  # Build object as expected by the map plugin
  def prepareMapMarkers(locations)
    workLocationsData = Hash.new
    markers = Hash.new
    count = 0
    
    # Add map config
    workLocationsData["center"] = { 'lat'=> 35.864716, 'lng'=> 2.349014, 'zoom'=> 1  }

    # Add layers: baselayers and overlays
    workLocationsData['layers'] = Hash.new
    
    # Add baselayers
    workLocationsData['layers']['baselayers'] = {
      'mapbox_light' => {
        'name' => 'Mapbox Light',
        'url' => 'http://api.tiles.mapbox.com/v4/{mapid}/{z}/{x}/{y}.png?access_token={apikey}',
        'type' => 'xyz',
        'layerOptions' => {
          'apikey' => 'pk.eyJ1IjoiYnVmYW51dm9scyIsImEiOiJLSURpX0pnIn0.2_9NrLz1U9bpwMQBhVk97Q',
          'mapid' => 'bufanuvols.lia22g09'
        }
      }
    }
    
    # Add overlays
    workLocationsData['layers']['overlays'] = Hash.new

    locations.each do | key, addrArray |
      
      # Build each marker and add to the list
      addrArray.each { |addr|
        marker = Hash.new
        count += 1
        puts addr
        
        # Build marker
        result = Geocoder.search(addr)

        marker['layer'] = key
        marker['lat'] = result[0].latitude
        marker['lng'] = result[0].longitude
        
        # Add to the list
        markers["addr" + "#{count}"] = marker
      }
      
      # Integrate markers
      workLocationsData['markers'] = Hash.new
      workLocationsData['markers'] = markers
      
      # Build overlays - allow removing data from the map
      workLocationsData['layers']['overlays'][key] = Hash.new
      workLocationsData['layers']['overlays'][key]['name'] = key
      workLocationsData['layers']['overlays'][key]['type'] = 'markercluster'
      workLocationsData['layers']['overlays'][key]['visible'] = true
    end
    
    return workLocationsData
  end
  
  def home
    locationsData = employeeLocationWidgetPrepare()
    @employeeLocationsData = prepareMapMarkers(locationsData)
    
    @invoices = salesFlowWidgetPrepare()
  end

  def help
  end
end
