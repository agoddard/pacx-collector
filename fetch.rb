require 'json'
require 'net/http'
require 'ap'

# test Airmar PB200 weather station on glider Benjamin


#If you don't specify any results variables, the results table will include columns for all of the variables in the dataset.

def fetch_data(dataset)
  base_url = "http://data.liquidr.com/erddap/tabledap"
  timerange = '>=2011-12-26T00:00:00Z'
  url = "#{base_url}/#{dataset}.json?&time#{timerange}"
  puts url
  resp = Net::HTTP.get_response(URI.parse(URI.encode(url)))
  data = resp.body
  result = JSON.parse(data)
  if result.has_key? 'Error'
    raise "API error"
  end
  return result
end


ap fetch_data('weatherBenjamin')

