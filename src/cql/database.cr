# An abstract Database object
abstract class CQL::Database
  getter :url
  getter :dialect

  def initialize(@dialect : CQL::Dialect, @url : String)
  end

  abstract def table_exists?(table_name : String)

  def create_table(table_name : String) : CQL::Command::CreateTable
    CQL::Command::CreateTable.new(self, table_name)
  end

  def insert(table_name : String) : CQL::Command::Insert
    CQL::Command::Insert.new(self, table_name)
  end

  def with_db(&block : DB::Database -> T) : T forall T
    DB.open(@url) do |db|
      yield db
    end
  end
end
