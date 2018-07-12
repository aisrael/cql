require "../../spec_helper"

describe CQL::Command::SelectOne do
  it "works" do
    ct = CQL::Command::SelectOne.new(CQL.postgres, "foo")
    ct.columns("id", "name")
    ct.where(id: 1)
    ct.to_s.should eq("SELECT id, name FROM foo WHERE id = $1")
  end
end
