# A Database object
class CQL::Database
  def self.postgres(database_url)
    PostgreSQL.new(database_url)
  end

  getter :url

  def initialize(@url : String)
  end

  class PostgreSQL < CQL::Database
  end
end
