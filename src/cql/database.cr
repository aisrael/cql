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

  def select(table_name : String) : CQL::Command::Select
    CQL::Command::Select.new(self, table_name)
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

  def exec(sql, args : Array(T)) : DB::ExecResult forall T
    debug {
      inject_args(sql, args)
    }
    db.exec(sql, args)
  end

  def exec(sql, *args) : DB::ExecResult
    debug {
      inject_args(sql, *args)
    }
    db.exec(sql, *args)
  end

  def scalar(sql, *args)
    debug {
      inject_args(sql, *args)
    }
    db.scalar(sql, *args)
  end

  # Directly query for one record and map it (really just delegates to the internal @db)
  def query_one(sql, *args, &block : DB::ResultSet -> U) : U forall U
    debug {
      inject_args(sql, *args)
    }
    db.query_one(sql, *args, &block)
  end

  # TODO: Move somewhere else?
  # TODO: Move somewhere else?
  private def inject_args(sql, args : Array(T)) forall T
    sql.gsub(/\$[0-9]+/) do |s|
      offset = s[1..-1].to_i
      if offset > 0 && offset <= args.size
        val = args[offset - 1]
        case val
        when String
          "'#{val}'"
        else
          val.to_s
        end
      else
        s
      end
    end
  end

  private def inject_args(sql, *args)
    inject_args(sql, args.to_a)
  end

  # Directly query for zero or one records and map it (really just delegates to the internal @db)
  def query_one?(sql, *args, &block : DB::ResultSet -> U) : U | Nil forall U
    debug do
      inject_args(sql, *args)
    end
    db.query_one?(sql, *args, &block)
  end

  # Directly query for multiple records and map them (really just delegates to the internal @db)
  def query_all(sql, *args, &block : DB::ResultSet -> U) : Array(U) forall U
    debug {
      inject_args(sql, *args)
    }
    db.query_all(sql, *args, &block)
  end
end
