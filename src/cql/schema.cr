require "db"
require "logging"

struct CQL::Schema(T)
  @column_names = {} of (String | Symbol) => (Int8.class | Int16.class | Int32.class | Int64.class | String.class)

  @resultset_mapper : DB::ResultSet -> T
  getter :resultset_mapper

  struct CQL::Schema::Selector(T)
    @resultset_mapper : DB::ResultSet -> T

    def initialize(
      @database : CQL::Database,
      @klass : T.class,
      @resultset_mapper : DB::ResultSet -> T,
      @table_name : String,
      @column_names : Array(String),
      @where : WhereClause? = nil
    )
    end

    def where(**where)
      new_where = {} of (String | Symbol) => CQL::Type
      if _where = @where
        _where.each { |k, v| new_where[k] = v }
      end
      where.each { |k, v| new_where[k] = v }
      Selector.new(@database, @klass, @resultset_mapper, @table_name, @column_names, new_where)
    end

    def all : Array(T)
      sql = self.to_s
      @database.query_all(sql, &@resultset_mapper)
    end

    def to_s(io)
      where_column_names = if w = @where
                             w.keys.map(&.to_s)
                           else
                             [] of String
                           end
      @database.dialect.select_statement(io, @table_name, @column_names, where_column_names)
    end
  end

  def initialize(@database : CQL::Database, @klass : T.class, @table_name : String, **columns)
    columns.each do |column_name, column_type|
      case column_type
      when Int8.class, Int16.class, Int32.class, Int64.class, String.class
        @column_names[column_name] = column_type
      else
        raise ArgumentError.new %(Unsupported class #{column_type.to_s}!)
      end
    end
    column_names = @column_names.keys.map(&.to_s) # Array(String)
    column_types = columns.values            # Tuple(*.class)
    @resultset_mapper = ->(rs : DB::ResultSet) do
      values = rs.read(*column_types)
      User.new(*values)
    end
    @selector = CQL::Schema::Selector(T).new(@database, @klass, @resultset_mapper, @table_name, column_names)
    @insert = CQL::Command::Insert.new(@database, @table_name, column_names.reject { |s| s == "id" })
  end

  getter :selector, :insert

  def count : Int64
    CQL::Command::Count.new(@database, @table_name).as_i64
  end

  def all : Array(T)
    selector.all
  end

  # Returns the default Selector
  def select : CQL::Schema::Selector(T)
    @selector
  end

  # Returns a custom CQL::Command::Select on the given expressions
  def select(*args : String) : CQL::Command::Select
    select_expressions = [] of String
    args.each { |s| select_expressions << s }
    self.select(select_expressions)
  end

  # Returns a custom CQL::Command::Select on the given expressions
  def select(select_expressions : ColumnNames) : CQL::Command::Select
    CQL::Command::Select.new(@database, @table_name, select_expressions)
  end

  # Returns the default CQL::Schema::Selector filtered by the given where clauses
  def where(**where_clause) : CQL::Schema::Selector(T)
    @selector.where(**where_clause)
  end
end
