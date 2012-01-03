require_relative 'pacx.rb'
require 'nokogiri'
require 'open-uri'

dataset = "ship"
data = build_triples(dataset)

base_url = "http://www.marinetraffic.com/ais/shipdetails.aspx?MMSI="

# find ships nearby
puts data

#test id
# id = 636091941 #cargo
id = 244212000 #fishing

page = Nokogiri::HTML(open("#{base_url}#{id}"))
detail = page.at('//div[starts-with(@id,"detailtext")]')
detail.children.each_with_index do |child,index|
  case child.text
  when 'Ship Type:'
    @ship_type_index = index + 1
  when 'Destination:'
    @ship_destination_index = index +1
  when 'Flag:'
    @ship_flag_index = index + 1
  when 'DeadWeight:'
    @ship_deadweight_index = index + 1
  when 'Speed recorded (Max / Average):'
    @ship_speed_index = index + 1
  end
end
ship_name = detail.xpath("//h1").first.text



#calculate heading and distance from glider





puts "We just passed the #{detail.children[@ship_type_index].to_s.split.first.downcase} vessel \"#{ship_name}\", she's a #{detail.children[@ship_flag_index].to_s.strip} flagged vessel on her way to #{detail.children[@ship_destination_index].to_s.strip.capitalize}"
