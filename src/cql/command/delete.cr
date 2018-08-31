struct CQL::Command::Delete < CQL::Command
  getter :table_name

  def initialize(@database : CQL::Database,
                 @table_name : String,
                 @where : WhereClause? = nil)
    super(@database)
  end

  def where(**where)
    new_where = {} of (String | Symbol) => CQL::Type
    if _where = @where
      _where.each { |k, v| new_where[k] = v }
    end
    where.each { |k, v| new_where[k] = v }
    Delete.new(@database, @table_name, new_where)
  end

  def exec(args : Array(U)) forall U
    @database.exec(self.to_s, args)
  end

  def exec(*args)
    @database.exec(self.to_s, *args)
  end

  def to_s(io)
    where_column_names = if w = @where
                           w.keys.map(&.to_s)
                         else
                           [] of String
                         end
    @database.dialect.delete_statement(io, table_name, where_column_names)
    io << ";"
  end
end
