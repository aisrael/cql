struct CQL::Command::CreateTable
  getter :table_name
  getter :columns

  @columns = [] of CQL::Column
  def initialize(@table_name : String)
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

  def to_s(io)
    io << "CREATE TABLE #{table_name} ("
    io << columns.map do |column|
      column.to_s
    end.join(", ")
    io << ");"
  end
end
