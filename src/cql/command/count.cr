struct CQL::Command::Count < CQL::Command
  include CQL::Command::WithWhereClause
  getter :table_name

  VALID_TABLE_NAME_PATTERN = /^[[:alpha:]][[:alpha:]0-9_]+$/
  def initialize(@database : CQL::Database, @table_name : String)
    raise ArgumentError.new(%(Invalid table name "#{@table_name}")) unless @table_name =~ VALID_TABLE_NAME_PATTERN
    super(@database)
  end

  def initialize(@database : CQL::Database, table : CQL::Table)
    initialize(@database, table.name)
  end

  def as_i64
    sql = to_s
    @database.scalar(sql).as(Int64)
  end

  # TODO: Move to CQL::Dialect?
  def to_s(io)
    io << "SELECT COUNT(*) FROM #{table_name};"
  end
end
