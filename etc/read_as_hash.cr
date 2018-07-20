list = ARGV[0]

puts "Hash{"
lines = File.each_line("./etc/#{list}.txt").map do |line|
  singular, plural = line.split(/:\s+/)
  %(  "#{singular}" => "#{plural}")
end
puts lines.join(",\n")
puts "}"
