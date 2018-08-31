require "../../spec_helper"

describe CQL::Command::Update do
  it "works" do
    update = CQL::Command::Update.new(CQL.postgres, "foo")
      .columns("name")
      .where(id: 1)
    update.to_s.should eq("UPDATE foo SET name = $1 WHERE id = $2")
  end
end
