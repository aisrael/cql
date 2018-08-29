module CQL
  abstract struct Command
    include Logging
    getter :database

    def initialize(@database : CQL::Database)
    end

    abstract struct WithTableName < CQL::Command
      getter :table_name

      VALID_TABLE_NAME_PATTERN = /^[[:alpha:]][[:alpha:]0-9_]+$/

      def initialize(@database : CQL::Database, table_name : String)
        raise ArgumentError.new(%(Invalid table name "#{table_name}")) unless table_name =~ VALID_TABLE_NAME_PATTERN
        @table_name = table_name
      end
    end

    abstract struct WithTableNameAndColumns < WithTableName
      getter :column_names

      @column_names = [] of String

      def column(name : String)
        self.class.new(@database, @table_name, @column_names + [name])
      end

      def columns(column_names : Array(String))
        self.class.new(@database, @table_name, @column_names.concat(column_names))
      end

      def columns(*args : String)
        columns(args.to_a)
      end
    end

    module WithWhereClause
      getter :where
      @where : WhereClause? = nil

      def where(**named_tuple)
        where_clause = WhereClause.new
        named_tuple.each do |key, value|
          where_clause[key.to_s] = value
        end
        clone_with_where(where_clause)
      end

      private abstract def clone_with_where(where : WhereClause)
    end
  end
end
