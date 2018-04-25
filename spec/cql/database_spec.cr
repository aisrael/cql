require "../db_helper"

describe CQL::Database do
  describe "#table_exists?" do
    it "returns true if a table with the given name exists" do
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

    it "returns false if a table with the name doesn't exist" do
      DB.open(DATABASE_URL) do |db|
        db.exec("DROP TABLE IF EXISTS foobar;")
      end
      db = CQL.postgres
      db.table_exists?("foobar").should be_false
    end
  end

  describe "#create_table" do
    it "returns a CQL::Command::CreateTable" do
      db = CQL.postgres
      result = db.create_table("foobar")
      result.should be_a(CQL::Command::CreateTable)
    end
    it "works" do
      db = CQL.postgres
      result = db.create_table("foobar").column("id", CQL::INTEGER).exec
      result.should be_a(DB::ExecResult)
      db.table_exists?("foobar").should be_true
    ensure
      DB.open(DATABASE_URL) do |db|
        db.exec("DROP TABLE IF EXISTS foobar;")
      end
    end
  end

  describe "#insert" do
    it "returns a CQL::Command::Insert" do
      db = CQL.postgres
      result = db.insert("foobar")
      result.should be_a(CQL::Command::Insert)
    end
    it "works" do
      DB.open(DATABASE_URL) do |db|
        db.exec("CREATE TABLE foobar (id INTEGER);")
      end

      db = CQL.postgres
      result = db.insert("foobar").column("id").exec(123)
      result.should be_a(DB::ExecResult)
      result.rows_affected.should eq(1)
      DB.open(DATABASE_URL) do |db|
        db.scalar("SELECT COUNT(id) FROM foobar WHERE id = 123;").as(Int).should eq(1)
      end
    ensure
      DB.open(DATABASE_URL) do |db|
        db.exec("DROP TABLE IF EXISTS foobar;")
      end
    end
  end
end
