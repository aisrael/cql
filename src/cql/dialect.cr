# A SQL "dialect". Meant to be extended by concrete implementations.
abstract class CQL::Dialect

  alias ColumnNames = Array(String)

  def insert_statement(io : IO, table_name : String, column_names : ColumnNames)
    io << "INSERT INTO "
    io << table_name
    io << " ("
    io << column_names.join(", ")
    io << ") VALUES ("
    io << value_placeholders_for(column_names).join(", ")
    io << ")"
  end

  abstract def value_placeholders_for(column_names : ColumnNames)

  abstract def column_equals_placeholders_for(column_names : ColumnNames, start_at = 1)

  def update_statement(io : IO, table_name : String, set : ColumnNames, where : ColumnNames)
    io << "UPDATE "
    io << table_name
    io << " SET "
    io << column_equals_placeholders_for(set).join(", ")
    return if where.empty?
    io << " WHERE "
    io << column_equals_placeholders_for(where, set.size).join(" AND ")
  end

  def delete_statement(io : IO, table_name : String, where : ColumnNames)
    io << "DELETE FROM "
    io << table_name
    return if where.empty?
    io << " WHERE "
    io << column_equals_placeholders_for(where).join(" AND ")
  end
end
