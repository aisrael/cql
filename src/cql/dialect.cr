# A SQL "dialect". Meant to be extended by concrete implementations.
abstract class CQL::Dialect
  def insert_statement(io : IO, table_name : String, column_names : Array(String))
    io << "INSERT INTO "
    io << table_name
    io << " ("
    io << column_names.join(", ")
    io << ") VALUES ("
    io << value_placeholders_for(column_names).join(", ")
    io << ");"
  end

  abstract def value_placeholders_for(column_names : Array(String))
end
