struct CQL::Command::Update < CQL::Command
  include CQL::Command::WithColumns
  include CQL::Command::WithWhereClause
  getter :table_name

  def initialize(@database : CQL::Database, @table_name : String)
    super(@database)
  end

  def exec(args : Array(U)) forall U
    sql = self.to_s
    debug sql
    @database.exec(self.to_s, args)
  end
  def exec(*args)
    sql = self.to_s
    debug sql
    @database.exec(self.to_s, *args)
  end
  def to_s(io)
    dialect = @database.dialect
    dialect.update_statement(io, table_name, column_names)
    return if @where.empty?
    io << " WHERE "
    where_clause = dialect.column_equals_placeholders_for(@where.keys, column_names.size + 1).join(" AND ")
    io << where_clause
  end
end
