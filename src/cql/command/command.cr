abstract struct CQL::Command
  include Logging
  getter :database

  def initialize(@database : CQL::Database)
  end
end
