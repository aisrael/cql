module CQL
  abstract struct Command
    include Logging
    getter :database

    def initialize(@database : CQL::Database)
    end

    module WithColumns
      getter :column_names

      @column_names = [] of String

      def column(name : String)
        @column_names << name
        self
      end
      def columns(column_names : Array(String))
        @column_names += column_names
        self
      end
      def columns(*args : String)
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
    end

    module WithWhereClause
      getter :where
      @where = {} of String => CQL::Type

      def where(**named_tuple)
        named_tuple.each do |key, value|
          @where[key.to_s] = value
        end
        self
      end
    end

  end
end
