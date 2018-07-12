struct CQL::Command::SelectOne < CQL::Command
  include CQL::Command::WithWhereClause
  include CQL::Command::WithColumns
  getter :table_name

  def initialize(@database : CQL::Database, @table_name : String)
    super(@database)
  end
  def exec(args : Array(T), &block : DB::ResultSet -> U) forall T, U
    sql = self.to_s
    debug sql
    @database.query_one(sql, args, &block)
  end
  def exec(*args, &block : DB::ResultSet -> U)
    sql = self.to_s
    debug sql
    @database.query_one(sql, *args, &block)
  end
  def to_s(io)
    @database.dialect.select_statement(io, table_name, @column_names, @where.keys)
  end
end
