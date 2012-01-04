require_relative 'pacx.rb'

measurements = %w(weather CTDox DatawellMOSE PowerStatus basic Fluorometer)
bots = %w(Benjamin PapaMau FontaineMaru PiccardMaru)

measurements.each do |measurement|
  bots.each do |bot|
    dataset = "#{measurement}#{bot}"
    data = build_triples(dataset)
    data.each do |collection|
      collection.each do |triple|
        puts "#{triple[:time].to_epoch},#{triple[:metric]},#{triple[:value]}"
      end
    end
  end
end
