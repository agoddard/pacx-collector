require 'json'
require 'net/http'
require 'date'
require 'time'

class DateTime
  def to_epoch
    self.to_time.to_i
  end
end


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
  collection = Array.new
  pacx = fetch_data(dataset)
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