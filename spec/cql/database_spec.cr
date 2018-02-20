require "../spec_helper"

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
      exec_result = db.insert("foobar").column("id").exec(123)
      exec_result.should be_a(DB::ExecResult)
      exec_result.rows_affected.should eq(1)
    ensure
      DB.open(DATABASE_URL) do |db|
        db.exec("DROP TABLE IF EXISTS foobar;")
      end
    end
  end
end
