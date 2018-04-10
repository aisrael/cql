struct CQL::Command::Delete < CQL::CommandWithWhereClause
  getter :table_name

  @column_names = [] of String
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
    @database.dialect.delete_statement(io, table_name, @where.keys)
    io << ";"
  end
end
