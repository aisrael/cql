require "../spec_helper"

describe Inflector do
  it "works" do
    File.each_line("etc/nouns.txt") do |line|
      singular, plural = line.split(/:\s+/)
      Inflector.pluralize(singular).should eq(plural)
    end
  end
end
