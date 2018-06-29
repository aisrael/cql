require "db"
require "logging"

# An abstract Database object
abstract class CQL::Database
  include Logging

  getter :url
  getter :dialect

  @db : DB::Database?

  def initialize(@dialect : CQL::Dialect, @url : String)
  end

  def db
    @db ||= DB.open(@url)
  end

  def close
    if d = @db
      d.close
      @db = nil
    end
  end

  abstract def table_exists?(table_name : String) : Bool

  def create_table(table : CQL::Table) : CQL::Command::CreateTable
    CQL::Command::CreateTable.new(self, table)
  end

  def create_table(table_name : String) : CQL::Command::CreateTable
    CQL::Command::CreateTable.new(self, table_name)
  end

  def delete_table(table : CQL::Table) : CQL::Command::DeleteTable
    CQL::Command::DeleteTable.new(self, table)
  end

  def insert(table_name : String) : CQL::Command::Insert
    CQL::Command::Insert.new(self, table_name)
  end

  def count(table_name : String) : CQL::Command::Count
    CQL::Command::Count.new(self, table_name)
  end

  def exec(sql, *args) : DB::ExecResult
    debug(sql)
    db.exec(sql, *args)
  end

  def scalar(sql, *args)
    db.scalar(sql, *args)
  end

  def query_all(sql, &block : DB::ResultSet -> U) : Array(U) forall U
    db.query_all(sql) do |rs|
      yield rs
    end
  end
end
