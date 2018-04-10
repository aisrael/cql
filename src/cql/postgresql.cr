require "logging"

# A concrete implementation of CQL::Database for PostgreSQL
class CQL::Database::PostgreSQL < CQL::Database
  include Logging

  def initialize(@url : String)
    super(CQL::Dialect::PostgreSQL::INSTANCE, @url)
  end

  def table_exists?(table_name : String) : Bool
    1i64 == db.scalar("SELECT COUNT(table_name)
    FROM information_schema.tables
    WHERE table_schema='public' AND table_name=$1;", table_name).as(Int)
  end
end

# A concrete implementation of CQL::Dialect for PostgreSQL
class CQL::Dialect::PostgreSQL < CQL::Dialect
  include Logging

  # The "singleton" instance
  INSTANCE = CQL::Dialect::PostgreSQL.new

  # Concrete implementation of the one in CQL::Dialect
  def value_placeholders_for(column_names : Array(String))
    column_names.size.times.map do |i|
      "$#{i + 1}"
    end.to_a
  end

  # Concrete implementation of the one in CQL::Dialect
  def column_equals_placeholders_for(column_names : ColumnNames, start_at = 1)
    column_names.map_with_index do |s, i|
      "#{s} = $#{i + start_at}"
    end
  end
end
