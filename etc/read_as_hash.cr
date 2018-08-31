list = ARGV[0]

puts "Hash{"
File.open(File.join(__DIR__, "#{list}.txt")) do |file|
  mapped = file.each_line.map do |line|
    singular, plural = line.split(/:\s+/)
    %(  "#{singular}" => "#{plural}")
  end
  puts mapped.join(",\n")
end
puts "}"
