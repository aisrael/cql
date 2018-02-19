require "../spec_helper"

describe CQL::Database do
  describe "#table_exists?" do
    it "returns true if the given table exists" do
      DB.open(DATABASE_URL) do |db|
        db.exec("CREATE TABLE foobar (id INTEGER);")
      end

      db = CQL.postgres
      db.table_exists?("foobar").should be_true
    ensure
      DB.open(DATABASE_URL) do |db|
        db.exec("DROP TABLE IF EXISTS foobar;")
      end
    end
  end
end
