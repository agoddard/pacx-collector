require 'json'
require 'net/http'
require 'ap'


def fetch_data(dataset)
  base_url = "http://data.liquidr.com/erddap/tabledap"
  timerange = '>=2011-12-26T00:00:00Z'
  url = "#{base_url}/#{dataset}.json?&time#{timerange}"
  resp = Net::HTTP.get_response(URI.parse(URI.encode(url)))
  data = resp.body
  result = JSON.parse(data)
  if result.has_key? 'Error'
    raise "API error"
  end
  return result
end

def build_triples(dataset)
  pacx = fetch_data(dataset)
  attributes = pacx['table']['columnNames'].size - 1
  columns = pacx['table']['columnNames']
  raise "time column is wrong" if columns[2] != 'time'
  pacx['table']['rows'].each_with_index do |record,index|
    (0..attributes).each do |i|
      puts "#{record[2]},#{dataset}.#{columns[i]},#{record[i]}"
    end
  end  
end


sources = %w(weather CTDox DatawellMOSE PowerStatus basic Fluorometer)
bots = %w(Benjamin FontaineMaru PapaMau PiccardMaru)

#Hermes and MBARIOAWaveGlider data having issues currently


sources.each do |source|
  bots.each do |bot|
    dataset = "#{source}#{bot}"
    build_triples(dataset)
  end
end