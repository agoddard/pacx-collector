require 'json'
require 'net/http'
require 'ap'

# test Airmar PB200 weather station on glider Benjamin


def fetch_data(dataset)
  base_url = "http://data.liquidr.com/erddap/tabledap"  
  # set attributes for now
  attributes = 'latitude,longitude,time,id,wVersion,flags,temperature,airPressure,avgWindSpeed,maxWindSpeed,stdDevWindSpeed,avgWindDirection,stdDevWindDir,nWindSamples&time>=2011-12-26T00:00:00Z'
  url = "#{base_url}/#{dataset}.json?#{attributes}"
  resp = Net::HTTP.get_response(URI.parse(URI.encode(url)))
  data = resp.body
  result = JSON.parse(data)
  if result.has_key? 'Error'
    raise "web service error"
  end
  return result
end


ap fetch_data('weatherBenjamin')

