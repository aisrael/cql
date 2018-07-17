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

  def create_table(table_name : String) : CQL::Command::CreateTable
    CQL::Command::CreateTable.new(self, table_name)
  end

  def create_table(table : CQL::Table) : CQL::Command::CreateTable
    CQL::Command::CreateTable.new(self, table)
  end

  def drop_table(table_name : String) : CQL::Command::DeleteTable
    CQL::Command::DeleteTable.new(self, table_name)
  end

  def drop_table(table : CQL::Table) : CQL::Command::DeleteTable
    CQL::Command::DeleteTable.new(self, table)
  end

  def select_one(table_name : String) : CQL::Command::SelectOne
  end

  def insert(table_name : String) : CQL::Command::Insert
    CQL::Command::Insert.new(self, table_name)
  end

  def update(table_name : String) : CQL::Command::Update
    CQL::Command::Update.new(self, table_name)
  end

  def count(table_name : String) : CQL::Command::Count
    CQL::Command::Count.new(self, table_name)
  end

  def exec(sql, *args) : DB::ExecResult
    debug(sql)
    db.exec(sql, *args)
  end

  def scalar(sql, *args)
    debug(sql)
    db.scalar(sql, *args)
  end

  # Directly query for one record and map it (really just delegates to the internal @db)
  def query_one(sql, *args, &block : DB::ResultSet -> U) : U forall U
    debug(sql)
    db.query_one(sql, *args, &block)
  end

  # Directly query for zero or one records and map it (really just delegates to the internal @db)
  def query_one?(sql, *args, &block : DB::ResultSet -> U) : U | Nil forall U
    debug(sql)
    db.query_one?(sql, *args, &block)
  end

  # Directly query for multiple records and map them (really just delegates to the internal @db)
  def query_all(sql, *args, &block : DB::ResultSet -> U) : Array(U) forall U
    debug(sql)
    db.query_all(sql, *args, &block)
  end
end
