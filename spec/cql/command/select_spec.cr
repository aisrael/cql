require "../../spec_helper"

describe CQL::Command::Select do
  it "can generate proper SQL" do
    ct = CQL::Command::Select.new(CQL.postgres, "foo")
      .columns("id", "name")
      .where(id: 1)
    ct.to_s.should eq("SELECT id, name FROM foo WHERE id = $1")
  end
end
