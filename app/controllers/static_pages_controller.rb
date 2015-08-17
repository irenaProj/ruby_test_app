class StaticPagesController < ApplicationController
  require 'multi_json'
  require 'httparty'
  require 'geocoder'
  
  # Class for retrieving data using Impac! API
  class RawData  
    # dataType - specifies the data to retrieve
    def initialize(dataType)  
      # Instance variables  
      @dataType  = dataType  
      @@username = "72db99d0-05dc-0133-cefe-22000a93862b"
      @@password = "_cIOpimIoDi3RIviWteOTA"
      @@url      = "http://api-impac-uat.maestrano.io/api/v1/get_widget"
    end  
    
    # Read raw data per type provided 
    def getMnoData  
      if @dataType == 'employees_list'
        params = MultiJson.load('{"engine":"hr/employees_list", 
                                  "metadata[organization_ids][]": "org-fbte"}')
      elsif @dataType == 'employee_details'
        params = MultiJson.load('{"engine":"hr/employee_details", 
                                  "metadata[organization_ids][]": "org-fbte"}')
      elsif @dataType == 'invoices'
        params = MultiJson.load('{"engine":"invoices/list", 
                                "metadata[organization_ids][]": "org-fbte", 
                                "metadata[entity]": "customers|suppliers"}')
      else
         raise StandardError
      end      
      
      auth = {username: @@username, password: @@password}
      options = {query: params, basic_auth: auth}
      
      @content = HTTParty.get(@@url, options)
    end  
  end  
  
  # Add common map details
  def finalizeMap(widgetType, data)
    
    # Add map config: center and zoom
    if widgetType == 'employee_details'
      data["center"] = { 'lat'=> 35.864716, 'lng'=> 10.349014, 'zoom'=> 1  }
    elsif widgetType == 'invoices'
      data["center"] = { 'lat'=> -23.6974800, 'lng'=> 133.8836200, 'zoom'=> 3 }
    else
      raise StandardError
    end
    
    # Add baselayers
    data['layers']['baselayers'] = {
      'mapbox_light' => {
        'name' => 'Mapbox Light',
        'url' => 'http://api.tiles.mapbox.com/v4/{mapid}/{z}/{x}/{y}.png?access_token={apikey}',
        'type' => 'xyz',
        'layerOptions' => {
          # Optional for the free service
          'apikey' => 'pk.eyJ1IjoiYnVmYW51dm9scyIsImEiOiJLSURpX0pnIn0.2_9NrLz1U9bpwMQBhVk97Q',
          'mapid' => 'bufanuvols.lia22g09'
        }
      }
    }
    
    return data
  end
  
  # Group all employees by city/country - for marker clustering
  def employeeLocationsByCity()
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
  
  # Prepare data to be displayed on "Employees location" widget - acquire raw data and process as following:
  # data received from hr/employees_list and hr/employee_details is almost identical, locations can be 
  # deducted based on employees_list only. In addition, "work_locations" key of some employees is empty and,
  # where exists - it specifies the location via ID only, thus, for the sake of the exercise, widget will 
  # be based on address field instead.
  def employeeLocationWidgetPrepare()
    workLocationsData = Hash.new
    markers = Hash.new
    count = 0

    # Add layers: baselayers and overlays
    workLocationsData['layers'] = Hash.new
    
    # Add overlays
    workLocationsData['layers']['overlays'] = Hash.new
    
    locations = employeeLocationsByCity()

    locations.each do | key, addrArray |
      
      # Build each marker and add to the list
      addrArray.each { |addr|
        marker = Hash.new
        count += 1

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
    
    return finalizeMap('employee_details', workLocationsData)
  end
  
  # Parse company address fields and attempt to create a valid address.
  # It is assumed all addresses are in Australia
  # The following manipulations are preformed to improve the address:
  # 1. If first address row contains P O Box substring, the row is ignored
  # 2. If address does not contain an 'AU', it is added to the end of the address
  # 3. Two addresses are prepared, one that contains the first line (if not P O Box),
  #    one without: if the full address fails, try the second one
  
  # Note: it is possible to go deeper and create more complex scenarios for
  # salvaging the address, here I attempted only to show that it is possible 
  # and support several basic cases
  def buildAddress(addrRaw)
    # Check if first address row contains P O Box substring
    isPoB = addrRaw['s'].include? "P O Box"
    location = Array.new

    fullLoc =  (addrRaw['s']  == "-" || isPoB) ? "" : "#{addrRaw['s']}, "
    partialLoc = (addrRaw['s2'] == "-") ? "" : "#{addrRaw['s2']}," 
    partialLoc += (addrRaw['l']  == "-") ? "" : "#{addrRaw['l']}, " 
    partialLoc += (addrRaw['r']  == "-") ? "" : "#{addrRaw['r']}, " 
    partialLoc += (addrRaw['z']  == "-") ? "" : "#{addrRaw['z']}, " 
    partialLoc += (addrRaw['c']  == "-") ? "" : "#{addrRaw['c']}"

    fullLoc += partialLoc

    # If address does not contain an 'AU', it is added to the end of the address
    if fullLoc != ""
      if fullLoc.exclude? "AU"
        # Set fullLoc as well as partialLoc in case all address was contained in the first line
        fullLoc += ", AU"
        partialLoc += ", AU"
      end
    end
    
    location[0] = fullLoc
    location[1] = partialLoc
    
    return location
  end
  
  # Prepare data to be displayed on "Sales flow" widget - acquire raw data and process as following:
  # Retrieve data via Impac! API, where "address" field contains enough data to allow geolocation,
  # add address and the invoice data to the records 
  def salesFlowWidgetPrepare()
    # Opacity set for the marker with lowest total
    min_opacity = 0.25
    
    # Maximal opacity (1) - min_opacity (0.4)
    opacity_range = 1 - min_opacity

    markers = Hash.new
    invoicesData = Hash.new
    minAmount = 1152921504606846976 # 2^60, should be enough
    maxAmount = -1
    recNum = 0
    
    invoicesList = (RawData.new("invoices").getMnoData())['content']['entities']
    
    invoicesList.each { | invoice |
      # First, extract 'address' field and check if contains enough details to identify on a map
      addrRaw = invoice['address']
      location = buildAddress(addrRaw)
      
      result = Array.new
      
      # Try the full address first
      if location[0] != ""
        result = Geocoder.search(location[0]) 
        
        if result.length != 1
          # Give the partial address a chance
          result = Geocoder.search(location[1]) 
        end
      end
      
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
    
    # Opacity range [0.25, 1], invoices range [minAmount, maxAmount],
    # calculate relative opacity for each marker 
    markers.each do | record, value |
      #puts "#{value}"
      if maxAmount > minAmount
        value['opacity'] = min_opacity + ((( value['total'] - minAmount) / ( maxAmount - minAmount )) * opacity_range)
      end

      # Field no longer needed
      value.delete 'total'
    end
    
    # Add baselayers - will be filled later
    invoicesData['layers'] = Hash.new
    
    # Integrate markers into the map structure
    invoicesData['markers'] = markers
    
    return finalizeMap('invoices', invoicesData)
  end  
  
  def home
    @employeeLocationsData = employeeLocationWidgetPrepare()
    @invoicesData = salesFlowWidgetPrepare()
  end

  def help
  end
end
