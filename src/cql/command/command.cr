abstract struct CQL::Command
  include Logging
  getter :database

  def initialize(@database : CQL::Database)
  end
end

abstract struct CQL::CommandWithWhereClause < CQL::Command
  getter :where
  @where = {} of String => CQL::Type

  def where(**named_tuple)
    named_tuple.each do |key, value|
      @where[key.to_s] = value
    end
  end
end
