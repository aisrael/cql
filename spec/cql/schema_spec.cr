require "../db_helper"

struct User
  getter :id, :name

  def initialize(@id : Int32, @name : String)
  end
end

describe CQL::Schema do
  it "works" do
    DB.open(DATABASE_URL) do |db|
      db.exec("DROP TABLE IF EXISTS users;")
      db.exec("CREATE TABLE users (id SERIAL, name VARCHAR(80));")
    end

    users_table = CQL::Schema.new(CQL.postgres, User,
      id: Int32,
      name: String
    )

    users_table.count.should eq(0)
    users_table.insert.values("test")
    users_table.count.should eq(1)

    users = users_table.all
    users.first.id.should eq(1)
    users.first.name.should eq("test")

    user_id_1 = users_table.where(id: 1).one
    user_id_1.id.should eq(1)
    user_id_1.name.should eq("test")

    users_named_test = users_table.where(name: "test").all
    users_named_test.first.id.should eq(1)
    users_named_test.first.name.should eq("test")

    deleted = users_table.where(id: 1).delete
    deleted.should eq(1)

    users_table.count.should eq(0)
  ensure
    DB.open(DATABASE_URL) do |db|
      db.exec("DROP TABLE IF EXISTS foobar;")
    end
  end
  describe "select" do
    it "supports narrowing the column names" do
      schema = CQL::Schema.new(CQL.postgres, User, "users",
        id: Int32,
        name: String
      )
      schema.select("name").to_s.should eq("SELECT name FROM users")
    end
  end
  describe "where" do
    it "returns a CQL::Schema::Selector(User)" do
      schema = CQL::Schema.new(CQL.postgres, User, "users",
        id: Int32,
        name: String
      )
      where_id_eq_1 = schema.where(id: 1)
      where_id_eq_1.should be_a(CQL::Schema::Selector(User))
      where_id_eq_1.to_s.should eq("SELECT id, name FROM users WHERE id = $1")
    end
  end
  describe "insert" do
    it "generates the correct SQL" do
      schema = CQL::Schema.new(CQL.postgres, User, "users",
        id: Int32,
        name: String
      )

      schema.insert.to_s.should eq("INSERT INTO users (name) VALUES ($1)")
    end
  end
end
