struct CQL::Command::CreateTable < CQL::Command
  getter :table_name
  getter :columns
  getter :constraints

  @constraints = [] of CQL::Table::TableConstraint

  VALID_TABLE_NAME_PATTERN = /^[[:alpha:]][[:alpha:]0-9_]+$/

  def initialize(@database : CQL::Database, @table_name : String)
    raise ArgumentError.new(%(Invalid table name "#{@table_name}")) unless @table_name =~ VALID_TABLE_NAME_PATTERN
    super(@database)
    @columns = [] of CQL::Column
  end

  def initialize(@database : CQL::Database, table : CQL::Table)
    initialize(@database, table.name)
    @columns = table.columns
    @constraints = table.constraints
  end

  def column(name : String,
             type : CQL::ColumnType,
             size : Int32? = nil,
             null : Bool? = nil,
             unique : Bool? = nil)
    @columns << CQL::Column.new(name: name,
      type: type,
      size: size,
      null: null,
      unique: unique
    )
    self
  end

  def exec
    sql = to_s
    debug sql
    @database.exec(sql)
  end

  # TODO: Move to CQL::Dialect?
  def to_s(io)
    io << "CREATE TABLE #{table_name} ("
    parts = columns.map(&.to_s)
    unless @constraints.empty?
      constraints.each do |constraint|
        s = "CONSTRAINT #{constraint.name} "
        if unique = constraint.unique
          s = s + "UNIQUE (#{unique.join(", ")})"
        end
        parts << s
      end
    end
    io << parts.join(", ")
    io << ");"
  end
end
