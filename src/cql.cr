require "./cql/*"

# A SQL toolkit for Crystal
module CQL

  private DATABASE_URL_KEY = "DATABASE_URL"

  # Returns a CQL::Database::PostgreSQL instance
  def self.postgres(database_url : String = ENV[DATABASE_URL_KEY])
    CQL::Database::PostgreSQL.new(database_url)
  end
end
