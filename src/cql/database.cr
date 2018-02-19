# A Database object
abstract class CQL::Database
  getter :url

  def initialize(@url : String)
  end

  abstract def table_exists?(table_name : String)

  def create_table(table_name : String) : CQL::Command::CreateTable
    CQL::Command::CreateTable.new(table_name)
  end

  class PostgreSQL < CQL::Database
    def table_exists?(table_name : String)
      with_db do |db|
        1i64 == db.scalar("SELECT COUNT(table_name)
        FROM information_schema.tables
        WHERE table_schema='public' AND table_name='#{table_name}';").as(Int)
      end
    end
  end

  def with_db(&block : DB::Database -> T) : T forall T
    DB.open(@url) do |db|
      yield db
    end
  end
end
