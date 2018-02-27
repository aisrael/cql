require "db"

# An abstract Database object
abstract class CQL::Database
  getter :url
  getter :dialect

  def initialize(@dialect : CQL::Dialect, @url : String)
  end

  abstract def table_exists?(table_name : String)

  def create_table(table : CQL::Table) : CQL::Command::CreateTable
    CQL::Command::CreateTable.new(self, table)
  end

  def create_table(table_name : String) : CQL::Command::CreateTable
    CQL::Command::CreateTable.new(self, table_name)
  end

  def insert(table_name : String) : CQL::Command::Insert
    CQL::Command::Insert.new(self, table_name)
  end

  def exec(sql, *args) : DB::ExecResult
    with_db do |db|
      db.exec(sql, *args)
    end
  end

  def query_all(sql, &block : DB::ResultSet -> U) : Array(U) forall U
    with_db do |db|
      db.query_all(sql) do |rs|
        yield rs
      end
    end
  end

  def with_db(&block : DB::Database -> T) : T forall T
    DB.open(@url) do |db|
      yield db
    end
  end
end
