struct CQL::Command::DeleteTable < CQL::Command
  getter :table_name

  VALID_TABLE_NAME_PATTERN = /^[[:alpha:]][[:alpha:]0-9_]+$/

  def initialize(@database : CQL::Database, @table_name : String)
    raise ArgumentError.new(%(Invalid table name "#{@table_name}")) unless @table_name =~ VALID_TABLE_NAME_PATTERN
    super(@database)
  end

  def initialize(@database : CQL::Database, table : CQL::Table)
    initialize(@database, table.name)
  end

  def exec
    sql = to_s
    @database.exec(sql)
  end

  # TODO: Move to CQL::Dialect
  def to_s(io)
    io << "DROP TABLE #{table_name};"
  end
end
