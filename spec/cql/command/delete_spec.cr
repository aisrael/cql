require "../../spec_helper"

describe CQL::Command::Delete do
  it "works" do
    delete = CQL::Command::Delete.new(CQL.postgres, "foobar")
      .where(id: 1)
    delete.to_s.should eq("DELETE FROM foobar WHERE id = $1;")
  end
  it "can accept multiple conditions in WHERE" do
    delete = CQL::Command::Delete.new(CQL.postgres, "foobar")
      .where(id: 1, code: "abc")
    delete.to_s.should eq("DELETE FROM foobar WHERE id = $1 AND code = $2;")
  end
end
