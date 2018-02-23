require "logging"

# A concrete implementation of CQL::Database for PostgreSQL
class CQL::Database::PostgreSQL < CQL::Database
  include Logging

  def initialize(@url : String)
    super(CQL::Dialect::PostgreSQL::INSTANCE, @url)
  end

  def table_exists?(table_name : String)
    with_db do |db|
      1i64 == db.scalar("SELECT COUNT(table_name)
      FROM information_schema.tables
      WHERE table_schema='public' AND table_name='#{table_name}';").as(Int)
    end
  end
end

# A concrete implementation of CQL::Dialect for PostgreSQL
class CQL::Dialect::PostgreSQL < CQL::Dialect
  include Logging

  # The "singleton" instance
  INSTANCE = CQL::Dialect::PostgreSQL.new

  # Override the default implementation in CQL::Dialect
  def value_placeholders_for(column_names : Array(String))
    column_names.size.times.map { |i| "$#{i + 1}"}
  end

end
