require "./spec_helper"

describe CQL do
  describe ".postgres" do
    it "returns a CQL::Database::PostgreSQL instance" do
      db = CQL.postgres("postgres://username:password@host/database")
      db.should be_a(CQL::Database::PostgreSQL)
      db.url.should eq("postgres://username:password@host/database")
    end
    it %(uses ENV["DATABASE_URL"] if no URL given) do
      ENV["DATABASE_URL"] ||= "postgres://username:password@host/database"
      db = CQL.postgres
      db.should be_a(CQL::Database::PostgreSQL)
      db.url.should eq(ENV["DATABASE_URL"])
    end
  end
end
