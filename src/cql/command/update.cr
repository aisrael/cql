struct CQL::Command::Update < CQL::Command::WithTableNameAndColumns
  include CQL::Command::WithWhereClause

  def initialize(
    @database : CQL::Database,
    @table_name : String,
    @column_names = [] of String, @where : WhereClause? = nil
  )
    super(@database, @table_name)
  end

  private def clone_with_where(where : WhereClause)
    CQL::Command::Update.new(@database, @table_name, @column_names, where)
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
    if where = @where
      dialect.update_statement(io, @table_name, column_names, where.keys.map(&.to_s))
    else
      dialect.update_statement(io, @table_name, column_names)
    end
  end
end
