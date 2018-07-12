require "yaml"
require "../spec_helper"

describe CQL::Dialect do
  # TODO We only support PostgreSQL for now anyway
  dialect = CQL::Dialect.dialect_for("postgres://")

  describe "update_statement" do
    it "works" do
      io = IO::Memory.new(1024)
      dialect.update_statement(io, "foo", ["id"])
      sql = io.to_s
      sql.should eq("UPDATE foo SET id = $1")
    end
  end
  describe "select_statement" do
    it "works" do
      io = IO::Memory.new(1024)
      dialect.select_statement(io, "foo", ["id", "name"], ["id"])
      sql = io.to_s
      sql.should eq("SELECT id, name FROM foo WHERE id = $1")
    end
  end
end
