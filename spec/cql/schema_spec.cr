require "../db_helper"

describe CQL::Schema do
  it "works" do
    DB.open(DATABASE_URL) do |db|
      db.exec("CREATE TABLE users (id INTEGER, name VARCHAR(80));")
    end

    schema = CQL::Schema.new(CQL.postgres, "users",
      id: Int32,
      name: String
    )
    schema.select.to_s.should eq("SELECT id, name FROM users")
  ensure
    DB.open(DATABASE_URL) do |db|
      db.exec("DROP TABLE IF EXISTS foobar;")
    end
  end
  describe "select" do
    it "supports narrowing the column names" do
      schema = CQL::Schema.new(CQL.postgres, "users",
        id: Int32,
        name: String
      )
      schema.select("name").to_s.should eq("SELECT name FROM users")
    end
  end
end
