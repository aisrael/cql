struct CQL::Command::Insert < CQL::Command
  getter :table_name
  getter :column_names

  @column_names = [] of String
  def initialize(@database : CQL::Database, @table_name : String)
    super(@database)
  end
  def column(name : String)
    @column_names << name
    self
  end
  def columns(column_names : Array(String))
    @column_names += column_names
    self
  end
  def columns(*args)
    args.each do |arg|
      case arg
      when String
        @column_names << arg
      else
        raise "Don't know how to handle column name of type #{arg.class}!"
      end
    end
    self
  end
  def exec(args : Array(U)) forall U
    sql = self.to_s
    debug sql
    @database.with_db do |db|
      db.exec(self.to_s, args)
    end
  end
  def exec(*args)
    sql = self.to_s
    debug sql
    @database.with_db do |db|
      db.exec(self.to_s, *args)
    end
  end
  def to_s(io)
    @database.dialect.insert_statement(io, table_name, column_names)
  end
end
