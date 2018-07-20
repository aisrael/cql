list = ARGV[0]

puts "Hash{"
lines = File.each_line(File.join(__DIR__, "#{list}.txt")).map do |line|
  singular, plural = line.split(/:\s+/)
  %(  "#{singular}" => "#{plural}")
end
puts lines.join(",\n")
puts "}"
