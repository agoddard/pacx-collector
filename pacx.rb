require 'json'
require 'net/http'
require 'date'
require 'time'
require 'awesome_print'


BOTS = %w(Benjamin PapaMau FontaineMaru PiccardMaru)

# find position of a glider
def glider_position(glider)
  # query position for the past 24 hrs, grab latest position
  time_start = (DateTime.now.to_time.utc-(60*60*24)).strftime("%Y-%m-%dT%H:%M:%SZ")
  data = fetch_data("basic#{glider}",">=#{time_start}")
  position = {:lat => data['table']['rows'][1][0], :long => data['table']['rows'][1][1], :time => data['table']['rows'][1][2]}
  return position
end

def find_ships
  # latest observation of AIS data for the past 48 hrs
  time_start = (DateTime.now.to_time.utc-(60*60*48)).strftime("%Y-%m-%dT%H:%M:%SZ")
  data = fetch_data("ship",">=#{time_start}")['table']['rows']
  ships = {}
  data.each do |row|
    ships[row[4]] = {:lat => row[0], :long => row[1], :time => row[2]}
  end
  return ships
end

def fetch_data(dataset,time)
  base_url = "http://data.liquidr.com/erddap/tabledap"
  url = "#{base_url}/#{dataset}.json?&time#{time}"
  resp = Net::HTTP.get_response(URI.parse(URI.encode(url)))
  data = resp.body
  result = JSON.parse(data)
  if result.has_key? 'Error'
    raise "API error"
  end
  return result
end

def build_triples(dataset, time)
  collection = Array.new
  pacx = fetch_data(dataset,time)
  columns = pacx['table']['columnNames']
  raise "time column is wrong" if columns[2] != 'time'
  pacx['table']['rows'].each_with_index do |record,index|
    triples = Array.new
    columns.each_with_index do |column, i|
      triples << { :time => DateTime.parse(record[2]), :metric => "#{dataset}.#{column}", :value => record[i] }
    end
    collection << triples
  end
  return collection
end