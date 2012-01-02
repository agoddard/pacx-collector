require_relative 'pacx.rb'

sources = %w(weather CTDox DatawellMOSE PowerStatus basic Fluorometer)
bots = %w(Benjamin PapaMau FontaineMaru PiccardMaru)

sources.each do |source|
  bots.each do |bot|
    dataset = "#{source}#{bot}"
    build_triples(dataset)
  end
end
