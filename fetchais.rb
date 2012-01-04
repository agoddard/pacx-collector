require_relative 'pacx.rb'
require 'nokogiri'
require 'open-uri'

dataset = "ship"


def titleize_ship(stroing)
  stroing.split.map{|w| w.capitalize}.join(' ').gsub('Ss','SS')
end

def ship_data(mssi_id)
  base_url = "http://www.marinetraffic.com/ais/shipdetails.aspx?MMSI="
  puts "#{base_url}#{mssi_id}"
  page = Nokogiri::HTML(open("#{base_url}#{mssi_id}"))

  raise "Ship not found" if page.at('//h2[contains(.,"Non-existent Vessel")]') || page.at('//h1[contains(.,"The requested service is unavailable.")]')

  detail = page.at('//div[starts-with(@id,"detailtext")]')
  ship = {}
  detail.children.each_with_index do |child,index|
    case child.text
    when 'Ship Type:'
      ship[:type] = extract_text(child.next_sibling).split.first.downcase
    when 'Destination:'
      ship[:destination] = extract_text(child.next_sibling).capitalize
    when 'Flag:'
      ship[:flag] = extract_text(child.next_sibling)
    when 'DeadWeight:'
      ship[:deadweight] = extract_text(child.next_sibling)
    when 'Speed recorded (Max / Average):'
      ship[:speed] = extract_text(child.next_sibling)
    end
  end
  ship[:name] = titleize_ship(detail.xpath("//h1").first.text)
  ship[:image] = page.css('img#picholder').first.attribute('src') rescue nil
  
  return ship
end

def extract_text(nokogiri_element)
  nbsp = Nokogiri::HTML("&nbsp;").text
  nokogiri_element.text.gsub(nbsp, " ").strip
end

def tweet(ship)
  message = "We just passed the #{ship[:type]} vessel #{ship[:name]}, she's a #{ship[:flag]} flagged vessel"
  message << " on her way to #{ship[:destination]}" unless ship[:destination].empty?
  message
end



data = build_triples(dataset)

# crank.filter.each

dedup={}

# find ships nearby
data.each do |collection|
  collection.each do |triple|
    begin
      puts tweet ship_data triple[:value] if triple[:metric] == "ship.MMSI" && !dedup[triple[:value]]
      dedup[triple[:value]] = true
    rescue RuntimeError
    end
  end
end

# puts tweet ship_data 636091941
# puts tweet ship_data 244212000
#test id
# id = 636091941 #cargo
# id = 244212000 #fishing
# puts tweet ship_data 636091941



# get first ship's sighting timestamp, ID, location, heading and speed


