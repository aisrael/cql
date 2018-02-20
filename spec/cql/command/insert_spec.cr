require "../../spec_helper"

describe CQL::Command::Insert do
  it "works" do
    ct = CQL::Command::Insert.new(CQL.postgres, "foobar")
    ct.column("id")
    ct.to_s.should eq("INSERT INTO foobar (id) VALUES ($1);")
  end
end
