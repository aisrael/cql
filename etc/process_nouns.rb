#!/usr/bin/env ruby

require 'active_support/core_ext/string'

AGID_INFL_TXT = "agid-2016.01.19/infl.txt"

nouns = File.readlines(AGID_INFL_TXT).select do |line|
  line =~ /(^\w+ N: .+[^?]$)/
end.map do |line|
  noun, plurals = *line.chomp.split(/\s+N:\s+/)
  plurals_array = plurals.split(/\s*,\s*/).map do |s|
    s = s.split(' ').first if s.index(' ')
    s[-1] == '?' ? s[0...-1] : s
  end.map(&:downcase).uniq
  [noun, plurals_array]
end

# compress
normalized = nouns.each_with_object({}) do |s_pa, h|
  noun, plurals_array = s_pa
  first = plurals_array.first
  singular = noun.downcase
  if h.has_key?(singular)
    if noun == singular
      # prefer lowercase inflections
      h[singular] = first
    end
  else
    # discard variants :p
    h[singular] = first
  end
end

File.open("nouns.txt", "w") do |f|
  normalized.each do |k, v|
    f.puts "#{k}: #{v}"
  end
end

RULES = [
  [/(.*)wolf$/, "\\1wolves"],
  [/(.*)ooth$/, "\\1eeth"],
  [/(.*)elf$/, "\\1elves"],
  [/(.+)eaf$/, "\\1eaves"],
  [/(.+)ife$/, "\\1ives"],
  [/(.+)oot$/, "\\1eet"],
  [/(.+)z$/, "\\0es"],
  [/(.*)ouse$/, "\\1ice"],
  [/(.+)ch$/, "\\0es"],
  [/(.+)x$/, "\\0es"],
  [/(.+)sh$/, "\\0es"],
  [/(.*)man$/, "\\1men"],
  [/(.+)um$/, "\\1a"],
  [/(.+)s$/, "\\0es"],
  [/(.+)us$/, "\\1i"],
  [/(.+)is$/, "\\1es"],
  [/(.+)y$/, "\\1ies"],
].reverse

@add_s = {}
# @add_es = {}
@irregular = {}
@uncountable = {}

def var_for(rule, replacement)
  k = rule.to_s[/(\w+)\$\)$/, 1]
  v = replacement[/([a-z]+)$/, 1]
  "@#{k}_#{v}"
end

RULES.each do |rule, replacement|
  eval "#{var_for(rule, replacement)} = {}"
end

# Make it a function so we can `return`
def process(singular, actual)
  RULES.each do |rule, replacement|
    if rule.match(singular)
      plural = singular.gsub(rule, replacement)
      if actual == plural
        eval "#{var_for(rule, replacement)}[singular] = [plural]"
        return
      end
      puts "#{singular} => actual: #{actual}, got: #{plural}"
      @irregular[singular] = actual
    end
  end
  if actual == singular
    @uncountable[singular] = actual
    return
  elsif actual == "#{singular}s"
    @add_s[singular] = actual
    return
  end
  @irregular[singular] = actual
end

normalized.each do |singular, plural|
  process(singular, plural)
end

COUNTS = {}

def dump_to(filename, hash)
  File.open("#{filename}.txt", "w") do |f|
    hash.each do |k, v|
      f.puts "#{k}: #{v}"
    end
  end
  COUNTS[filename] = hash.size
end

%w[uncountable add_s irregular].each do |f|
  dump_to(f, eval("@#{f}"))
end

RULES.each do |k, vv|
  dump_to(var_for(k, vv)[1..-1], eval(var_for(k, vv)))
end

COUNTS.to_a.sort_by {|a| a[1]}.reverse.each do |filename, count|
  puts "#{filename}: #{count}"
end
