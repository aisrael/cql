struct CQL::Command::CreateTable
  getter :table_name
  getter :columns

  alias ColumnDef = NamedTuple(name: String,
                    type: String,
                    size: Int32?,
                    null: Bool?,
                    unique: Bool?)
  @columns = [] of ColumnDef
  def initialize(@table_name : String)
  end
  def column(name : String,
    type : String,
    size : Int32? = nil,
    null : Bool? = nil,
    unique : Bool? = nil)
    @columns << {
      name: name,
      type: type,
      size: size,
      null: null,
      unique: unique
    }
    self
  end

  def to_s(io)
    io << "CREATE TABLE #{table_name} ("
    io << columns.map do |column_def|
      column_def_to_s(column_def)
    end.join(", ")
    io << ");"
  end

  private def column_def_to_s(column_def)
    parts = [column_def[:name]]
    case column_def[:type]
    when "CHAR", "VARCHAR"
      if column_def[:size]
        parts << "#{column_def[:type]}(#{column_def[:size]})"
      else
        parts << column_def[:type]
      end
    else
      parts << column_def[:type]
    end
    parts.join(" ")
  end
end
