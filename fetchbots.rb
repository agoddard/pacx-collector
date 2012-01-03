require_relative 'pacx.rb'

sources = %w(weather CTDox DatawellMOSE PowerStatus basic Fluorometer)
bots = %w(Benjamin PapaMau FontaineMaru PiccardMaru)

sources.each do |source|
  bots.each do |bot|
    dataset = "#{source}#{bot}"
    data = build_triples(dataset)
    data.each do |collection|
      collection.each do |triple|
        puts "#{triple[:time].to_epoch},#{triple[:metric]},#{triple[:value]}"
      end
    end
  end
end
