require_relative 'pacx.rb'
require 'nokogiri'
require 'open-uri'
require 'haversine'


def titleize_ship(ship_name)
  ship_name.split.map{|w| w.capitalize}.join(' ').gsub('Ss','SS')
end

def ship_data(mssi_id)
  base_url = "http://www.marinetraffic.com/ais/shipdetails.aspx?MMSI="
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
  ship[:image] = page.css('img#picholder').first.attribute('src').to_s rescue nil
  return ship
end

def extract_text(nokogiri_element)
  nbsp = Nokogiri::HTML("&nbsp;").text
  nokogiri_element.text.gsub(nbsp, " ").strip
end

def tweet(glider,ship,distance)
  message = "#{glider} just noticed the #{ship[:type]} vessel #{ship[:name]}, she's a #{ship[:flag]} flagged vessel"
  message << " on her way to #{ship[:destination]}" unless ship[:destination].empty?
  message << " (image: #{ship[:image]})" unless ship[:image].empty?
  message << ". She's currently #{distance.round(2)} km away from #{glider}"
  message
end



def distance_to_glider(glider,ship_location)
  bot = glider_position(glider)
  Haversine.distance([bot[:lat],bot[:long]], [ship_location[:lat],ship_location[:long]]).to_km
end


find_ships.each do |mssi_id,ship_location|
  BOTS.each do |glider|
    puts tweet(glider,ship_data(mssi_id),distance_to_glider(glider,ship_location)) rescue nil
  end
end
