struct CQL::Command::Select < CQL::Command
  getter :table_name, :column_names

  def initialize(@database : CQL::Database,
                 @table_name : String,
                 @column_names = [] of String,
                 @where : WhereClause? = nil)
    super(@database)
  end

  def columns(*column_names : String)
    # Make a new Array(String) to preserve immutability
    new_column_names = [] of String + @column_names
    column_names.each { |column_name| new_column_names << column_name }
    Select.new(@database, @table_name, new_column_names, @where)
  end

  def where(**where)
    new_where = {} of (String | Symbol) => CQL::Type
    if _where = @where
      _where.each { |k, v| new_where[k] = v }
    end
    where.each { |k, v| new_where[k] = v }
    Select.new(@database, @table_name, @column_names, new_where)
  end

  def all(&block : DB::ResultSet -> U) : Array(U) forall U
    sql = self.to_s
    if where = @where
      params = where.values
      @database.query_all(sql, params, &block)
    else
      @database.query_all(sql, &block)
    end
  end

  def one(&block : DB::ResultSet -> U) : U forall U
    sql = self.to_s
    if where = @where
      params = where.values
      @database.query_one(sql, params, &block)
    else
      @database.query_one(sql, &block)
    end
  end

  def one?(&block : DB::ResultSet -> U) : U forall U
    sql = self.to_s
    if where = @where
      params = where.values
      @database.query_one?(sql, params, &block)
    else
      @database.query_one?(sql, &block)
    end
  end

  def to_s(io)
    where_column_names = if w = @where
                           w.keys.map(&.to_s)
                         else
                           [] of String
                         end
    @database.dialect.select_statement(io, table_name, @column_names, where_column_names)
  end
end
