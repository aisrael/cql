require "uri"

# A SQL toolkit for Crystal
module CQL
  private DATABASE_URL_KEY = "DATABASE_URL"

  # Column types
  # TODO: Make a type or enum
  CHAR = "CHAR"
  SERIAL = "SERIAL"
  TIMESTAMP = "TIMESTAMP"
  VARCHAR = "VARCHAR"

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
