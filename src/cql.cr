require "uri"

# A SQL toolkit for Crystal
module CQL
  private DATABASE_URL_KEY = "DATABASE_URL"

  # Value types
  alias Type = Int8 | Int32 | Int64 | String

  # Column types
  enum ColumnType
    BOOLEAN
    CHAR
    INTEGER
    SERIAL
    TIMESTAMP
    VARCHAR
  end
  BOOLEAN = ColumnType::BOOLEAN
  CHAR = ColumnType::CHAR
  INTEGER = ColumnType::INTEGER
  SERIAL = ColumnType::SERIAL
  TIMESTAMP = ColumnType::TIMESTAMP
  VARCHAR = ColumnType::VARCHAR

  KNOWN_DATABASES = {
    "postgres" => CQL::Database::PostgreSQL
  }

  # Returns a CQL::Database instance based on the URL scheme
  # Currently only supports "postgres://"
  def self.connect(database_url : String = ENV[DATABASE_URL_KEY]) : CQL::Database
    uri = URI.parse(database_url)
    scheme = uri.scheme
    if scheme.nil?
      raise Exception.new "Database URL scheme is nil!"
    elsif !KNOWN_DATABASES.has_key?(scheme)
      raise Exception.new %(Unknown database scheme "#{scheme}")
    end
    KNOWN_DATABASES[scheme].new(database_url)
  end

  # Returns a CQL::Database::PostgreSQL instance
  def self.postgres(database_url : String = ENV[DATABASE_URL_KEY]) : CQL::Database
    KNOWN_DATABASES["postgres"].new(database_url)
  end
end

require "./cql/*"
require "./cql/command/*"
