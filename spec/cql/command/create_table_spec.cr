require "../../spec_helper"

describe CQL::Command::CreateTable do
  it "works" do
    ct = CQL::Command::CreateTable.new(CQL.postgres, "foobar")
    ct.column("id", "SERIAL")
    sql = String.build do |s|
      ct.to_s(s)
    end
    sql.should eq("CREATE TABLE foobar (id SERIAL);")
  end
end
