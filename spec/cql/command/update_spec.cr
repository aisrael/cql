require "../../spec_helper"

describe CQL::Command::Update do
  it "works" do
    ct = CQL::Command::Update.new(CQL.postgres, "foo")
    ct.columns("name")
    ct.where(id: 1)
    ct.to_s.should eq("UPDATE foo SET name = $1 WHERE id = $2")
  end
end
