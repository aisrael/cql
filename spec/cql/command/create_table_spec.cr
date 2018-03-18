require "../../spec_helper"

describe CQL::Command::CreateTable do
  it "works" do
    ct = CQL::Command::CreateTable.new(CQL.postgres, "foobar")
    ct.column("id", CQL::SERIAL)
    sql = String.build do |s|
      ct.to_s(s)
    end
    sql.should eq("CREATE TABLE foobar (id SERIAL);")
  end
  it "raises an ArgumentError if the table name is invalid" do
    expect_raises(ArgumentError) do
      CQL::Command::CreateTable.new(CQL.postgres, "")
    end.message.should eq(%(Invalid table name ""))
    expect_raises(ArgumentError) do
      CQL::Command::CreateTable.new(CQL.postgres, "_starts_with_underscore")
    end.message.should eq(%(Invalid table name "_starts_with_underscore"))
    expect_raises(ArgumentError) do
      CQL::Command::CreateTable.new(CQL.postgres, "1starts_with_digit")
    end.message.should eq(%(Invalid table name "1starts_with_digit"))
    expect_raises(ArgumentError) do
      CQL::Command::CreateTable.new(CQL.postgres, "contains'singlequote")
    end.message.should eq(%(Invalid table name "contains'singlequote"))
    expect_raises(ArgumentError) do
      CQL::Command::CreateTable.new(CQL.postgres, %(contains"doublequote))
    end.message.should eq(%(Invalid table name "contains"doublequote"))
    expect_raises(ArgumentError) do
      CQL::Command::CreateTable.new(CQL.postgres, "contains,comma")
    end.message.should eq(%(Invalid table name "contains,comma"))
    expect_raises(ArgumentError) do
      CQL::Command::CreateTable.new(CQL.postgres, "contains;semicolon")
    end.message.should eq(%(Invalid table name "contains;semicolon"))
  end
end
