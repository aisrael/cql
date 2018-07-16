struct CQL::Command::Insert < CQL::Command
  getter :table_name
  getter :column_names

  def initialize(@database : CQL::Database, @table_name : String, @column_names = [] of String)
    super(@database)
  end

  def column(name : String)
    new_column_names = @column_names + [name]
    Insert.new(@database, @table_name, new_column_names)
  end

  def columns(column_names : Array(String))
    new_column_names = @column_names + column_names
    Insert.new(@database, @table_name, new_column_names)
  end

  def columns(*column_names : String)
    new_column_names = [] of String + @column_names
    column_names.each { |column_name| new_column_names << column_name }
    Insert.new(@database, @table_name, new_column_names)
  end

  def exec(args : Array(U)) forall U
    @database.exec(self.to_s, args)
  end

  def values(*args)
    @database.exec(self.to_s, *args)
  end

  def exec(*args)
    @database.exec(self.to_s, *args)
  end

  def to_s(io)
    @database.dialect.insert_statement(io, table_name, column_names)
  end
end
