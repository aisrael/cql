require "db"
require "logging"

struct CQL::Schema(T)
  @columns = {} of (String | Symbol) => (Int8.class | Int16.class | Int32.class | Int64.class | String.class)

  @resultset_mapper : DB::ResultSet -> T
  getter :resultset_mapper

  def initialize(@database : CQL::Database, @klass : T.class, @table_name : String, **columns)
    columns.each do |column_name, column_type|
      case column_type
      when Int8.class, Int16.class, Int32.class, Int64.class, String.class
        @columns[column_name] = column_type
      else
        raise ArgumentError.new %(Unsupported class #{column_type.to_s}!)
      end
    end
    column_names = @columns.keys.map(&.to_s)
    column_types = @columns.values
    @select = CQL::Command::Select.new(@database, @table_name, column_names)
    @insert = CQL::Command::Insert.new(@database, @table_name, column_names.reject { |s| s == "id" })
    types = columns.values
    @resultset_mapper = ->(rs : DB::ResultSet) do
      values = rs.read(*types)
      User.new(*values)
    end
  end

  getter :select, :insert

  def count : Int64
    CQL::Command::Count.new(@database, @table_name).as_i64
  end

  def all : Array(T)
    self.select.all(&@resultset_mapper)
  end

  def select(*args : String) : CQL::Command::Select
    select_expressions = [] of String
    args.each { |s| select_expressions << s }
    self.select(select_expressions)
  end

  def select(select_expressions : ColumnNames) : CQL::Command::Select
    CQL::Command::Select.new(@database, @table_name, select_expressions)
  end

  def where(**where_clause)
    @select.where(**where_clause)
  end
end
