struct CQL::Command::Select < CQL::Command
  getter :table_name, :column_names

  def initialize(@database : CQL::Database,
                 @table_name : String,
                 @column_names = [] of String,
                 @where = {} of (String | Symbol) => CQL::Type)
    super(@database)
  end

  def columns(*new_column_names : String)
    # Make a new Array(String) to preserve immutability
    column_names = [] of String
    column_names.concat(@column_names)
    new_column_names.each { |column_name| column_names << column_name }
    Select.new(@database, @table_name, column_names, @where)
  end

  def where(**new_where)
    where = {} of (String | Symbol) => CQL::Type
    @where.each {|k, v| where[k] = v}
    new_where.each {|k, v| where[k] = v}
    Select.new(@database, @table_name, @column_names, where)
  end

  def to_s(io)
    @database.dialect.select_statement(io, table_name, @column_names, @where.keys.map(&.to_s))
  end
end
