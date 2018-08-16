require "../spec_helper"

describe Inflector do
  it "works with all the nouns in the AGID list" do
    File.each_line("etc/nouns.txt") do |line|
      singular, plural = line.split(/:\s+/)
      Inflector.pluralize(singular).should eq(plural)
    end
  end
  it "works with some arbitrary underscored strings" do
    Inflector.pluralize("user_profile").should eq("user_profiles")
    Inflector.pluralize("dark_elf").should eq("dark_elves")
  end
end
