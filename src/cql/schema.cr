require "db"
require "logging"

struct CQL::Schema(T)
  @column_names = {} of (String | Symbol) => (Int8.class | Int16.class | Int32.class | Int64.class | String.class | Time.class)

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

    # Returns the CQL::Command::Select corresponding to this Selector
    def to_select
      @select ||= CQL::Command::Select.new(@database, @table_name, @column_names, @where)
    end

    def sql
      self.to_s
    end

    def one : T
      to_select.one(&@resultset_mapper)
    end

    def one? : T?
      to_select.one?(&@resultset_mapper)
    end

    def all : Array(T)
      to_select.all(&@resultset_mapper)
    end

    def delete : Int64
      delete = CQL::Command::Delete.new(@database, @table_name, @where)
      exec_result = if where = @where
                      params = where.values
                      delete.exec(params)
                    else
                      delete.exec
                    end
      exec_result.rows_affected
    end

    def to_s(io)
      to_select.to_s(io)
    end
  end

  # Create a Schema using the plural form of the given class name (using Inflector). For example:
  #
  #   CQL::Schema.new(CQL.connect, User, id: Int32, name: String)
  #
  # Which is equivalent to:
  #
  #   CQL::Schema.new(CQL.connect, User, "users", id: Int32, name: String)
  #
  def initialize(@database : CQL::Database, @klass : T.class, **columns)
    initialize(@database, @klass, Inflector.pluralize(@klass.name.downcase), **columns)
  end

  # Create a Schema for the given class, specifying the table name, columns and their types.
  #
  #   CQL::Schema.new(CQL.connect, User, "users", id: Int32, name: String)
  #
  def initialize(@database : CQL::Database, @klass : T.class, @table_name : String, **columns)
    columns.each do |column_name, column_type|
      case column_type
      when Int8.class, Int16.class, Int32.class, Int64.class, String.class, Time.class
        @column_names[column_name] = column_type
      else
        raise ArgumentError.new %(Unsupported class #{column_type.to_s}!)
      end
    end
    column_names = @column_names.keys.map(&.to_s) # Array(String)
    column_types = columns.values                 # Tuple(*.class)
    @resultset_mapper = ->(rs : DB::ResultSet) do
      values = rs.read(*column_types)
      @klass.new(*values)
    end
    @selector = CQL::Schema::Selector(T).new(@database, @klass, @resultset_mapper, @table_name, column_names)
  end

  getter :selector

  def insert
    @insert ||= begin
      column_names = @column_names.keys.map(&.to_s) # Array(String)
      CQL::Command::Insert.new(@database, @table_name, column_names.reject { |s| s == "id" })
    end
  end

  def insert(*column_names : String)
    @database.insert(@table_name).columns(*column_names)
  end

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
