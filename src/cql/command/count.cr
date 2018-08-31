struct CQL::Command::Count < CQL::Command::WithTableName
  include CQL::Command::WithWhereClause
  getter :table_name

  def initialize(@database : CQL::Database, @table_name : String, @where : WhereClause? = nil)
    super(@database, @table_name)
  end

  def initialize(@database : CQL::Database, table : CQL::Table)
    initialize(@database, table.name)
  end

  private def clone_with_where(where : WhereClause)
    self.class.new(@database, @table_name, where)
  end

  def as_i64
    sql = to_s
    @database.scalar(sql).as(Int64)
  end

  # TODO: Move to CQL::Dialect?
  def to_s(io)
    dialect = @database.dialect
    if where = @where
      dialect.count_statement(io, @table_name, where.keys.map(&.to_s))
    else
      dialect.count_statement(io, @table_name)
    end
  end
end
