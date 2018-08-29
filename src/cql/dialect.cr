# A SQL "dialect". Meant to be extended by concrete implementations.
abstract class CQL::Dialect
  VALID_TABLE_NAME_PATTERN = /^[[:alpha:]][[:alpha:]0-9_]+$/

  SUPPORTED_DIALECTS = {
    "postgres"   => CQL::Dialect::PostgreSQL::INSTANCE,
    "postgresql" => CQL::Dialect::PostgreSQL::INSTANCE,
  }

  # Returns a CQL::Dialect instance based on the URL scheme in ENV["DATABASE_URL"]
  # Currently only supports "postgres://"
  def self.default : CQL::Dialect
    database_url = ENV[DATABASE_URL_KEY]
    raise Exception.new "$DATABASE_URL_KEY is not set or empty!" if database_url.nil? || database_url.empty?
    dialect_for(database_url)
  end

  # Returns a CQL::Dialect instance based on the URL scheme
  # Currently only supports "postgres://"
  def self.dialect_for(database_url : String) : CQL::Dialect
    uri = URI.parse(database_url)
    scheme = uri.scheme
    if scheme.nil?
      raise Exception.new "Database URL scheme is nil!"
    elsif !KNOWN_DATABASES.has_key?(scheme)
      raise Exception.new %(Unknown database scheme "#{scheme}"! CQL currently only supports "postgres://" or "postgresql://")
    end
    SUPPORTED_DIALECTS[scheme]
  end

  # TODO: Make abstract?
  def valid_table_name?(table_name : String) : Bool
    table_name =~ VALID_TABLE_NAME_PATTERN
  end

  # TODO: Make abstract?
  def insert_statement(io : IO, table_name : String, column_names : ColumnNames)
    io << "INSERT INTO "
    io << table_name
    io << " ("
    io << column_names.join(", ")
    io << ") VALUES ("
    io << value_placeholders_for(column_names).join(", ")
    io << ")"
  end

  # TODO: Make abstract?
  def update_statement(io : IO, table_name : String, column_names : ColumnNames)
    io << "UPDATE " << table_name << " SET " << column_equals_placeholders_for(column_names).join(", ")
  end

  def update_statement(io : IO, table_name : String, column_names : ColumnNames, where_column_names : ColumnNames)
    update_statement(io, table_name, column_names)
    return if where_column_names.empty?
    io << " WHERE " << column_equals_placeholders_for(where_column_names, column_names.size + 1).join(" AND ")
  end

  def select_statement(io : IO, table_name : String, column_names : ColumnNames, where : ColumnNames)
    io << "SELECT " << column_names.join(", ") << " FROM " << table_name
    return if where.empty?
    io << " WHERE " << column_equals_placeholders_for(where).join(" AND ")
  end

  abstract def value_placeholders_for(column_names : ColumnNames)

  abstract def column_equals_placeholders_for(column_names : ColumnNames, start_at = 1)

  def delete_statement(io : IO, table_name : String, where_column_names : ColumnNames)
    io << "DELETE FROM "
    io << table_name
    return if where_column_names.empty?
    io << " WHERE "
    io << column_equals_placeholders_for(where_column_names).join(" AND ")
  end

  def count_statement(io : IO, table_name : String, where_column_names : ColumnNames = [] of String, count_what = "*")
    io << "SELECT COUNT(" << count_what << ") FROM " << table_name
    return if where_column_names.empty?
    io << " WHERE "
    io << column_equals_placeholders_for(where_column_names).join(" AND ")
  end
end
