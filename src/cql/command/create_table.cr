struct CQL::Command::CreateTable < CQL::Command
  getter :table_name
  getter :columns

  def initialize(@database : CQL::Database, @table_name : String)
    super(@database)
    @columns = [] of CQL::Column
  end

  def initialize(@database : CQL::Database, table : CQL::Table)
    @table_name = table.name
    @columns = table.columns
  end

  def column(name : String,
    type : String,
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
    sql = self.to_s
    debug sql
    @database.with_db do |db|
      db.exec(self.to_s)
    end
  end
  # TODO: Move to CQL::Dialect?
  def to_s(io)
    io << "CREATE TABLE #{table_name} ("
    io << columns.map do |column|
      column.to_s
    end.join(", ")
    io << ");"
  end
end
