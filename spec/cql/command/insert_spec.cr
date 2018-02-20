require "../../spec_helper"

describe CQL::Command::Insert do
  it "works" do
    ct = CQL::Command::Insert.new(CQL.postgres, "foobar")
    ct.column("id")
    ct.to_s.should eq("INSERT INTO foobar (id) VALUES ($1);")
  end
  it "can accept multiple column names using #columns" do
    ct = CQL::Command::Insert.new(CQL.postgres, "foobar")
    ct.columns("id", "name")
    ct.to_s.should eq("INSERT INTO foobar (id, name) VALUES ($1, $2);")
  end
end
