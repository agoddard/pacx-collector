require_relative 'pacx.rb'

measurements = %w(weather CTDox DatawellMOSE PowerStatus basic Fluorometer)

time_start = "2012-01-01T00:00:00Z"

measurements.each do |measurement|
  BOTS.each do |bot|
    dataset = "#{measurement}#{bot}"
    data = build_triples(dataset,">=#{time_start}")
    data.each do |collection|
      collection.each do |triple|
        puts "#{triple[:time].to_time.to_i},#{triple[:metric]},#{triple[:value]}"
      end
    end
  end
end
