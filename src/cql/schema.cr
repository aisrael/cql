require "db"
require "logging"

struct CQL::Schema
  @columns = {} of (String | Symbol) => (Int8.class | Int16.class | Int32.class | Int64.class | String.class)
  def initialize(@database : CQL::Database, @table_name : String, **columns)
    columns.each do |column_name, column_type|
      case column_type
      when Int8.class, Int16.class, Int32.class, Int64.class, String.class
        @columns[column_name] = column_type
      else
        raise ArgumentError.new %(Unsupported class #{column_type.to_s}!)
      end
    end
  end

  def select : CQL::Command::Select
    self.select(@columns.keys.map(&.to_s))
  end


  def select(*args : String) : CQL::Command::Select
    select_expressions = [] of String
    args.each {|s| select_expressions << s}
    self.select(select_expressions)
  end

  def select(select_expressions : ColumnNames) : CQL::Command::Select
    @select ||= CQL::Command::Select.new(@database, @table_name, select_expressions)
  end

end
