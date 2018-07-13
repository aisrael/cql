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
  describe ".connect" do
    it %(supports "postgres" or "postgresql") do
      CQL.connect("postgres://username:password@host/database").should be_a(CQL::Database::PostgreSQL)
      CQL.connect("postgresql://username:password@host/database").should be_a(CQL::Database::PostgreSQL)
    end
    it "raise an error if no scheme or unidentified scheme" do
      expect_raises Exception, "Database URL scheme is nil!" do
        CQL.connect("localhost")
      end
      expect_raises Exception, %(Unknown database scheme "oracle"! CQL currently only supports "postgres://" or "postgresql://") do
        CQL.connect("oracle://localhost")
      end
    end
  end
end
