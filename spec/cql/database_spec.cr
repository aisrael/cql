require "../spec_helper"

describe CQL::Database do
  describe ".postgres" do
    it "returns a CQL::Database::PostgreSQL instance" do
      db = CQL::Database.postgres("postgres://username:password@host/database")
      db.should be_a(CQL::Database::PostgreSQL)
      db.url.should eq("postgres://username:password@host/database")
    end
  end
end
