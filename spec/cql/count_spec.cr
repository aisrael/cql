require "spec2"
require "../../spec_helper"

Spec2.describe CQL::Command::Count do
  it "works" do
    delete = CQL::Command::Count.new(CQL.postgres, "foobar")
      .where(id: 1)
    expect(delete.to_s).to eq("SELECT COUNT(*) FROM foobar WHERE id = $1")
  end
  it "can accept multiple conditions in WHERE" do
    delete = CQL::Command::Count.new(CQL.postgres, "foobar")
      .where(id: 1, code: "abc")
    expect(delete.to_s).to eq("SELECT COUNT(*) FROM foobar WHERE id = $1 AND code = $2")
  end
end
