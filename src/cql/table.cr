require "./column"

class CQL::Table
  property :name
  getter :columns, :constraints
  @columns = [] of Column
  @constraints = [] of TableConstraint

  # Defines a new SQL Table with the given name
  def initialize(@name : String)
  end

  def self.from_yaml(yaml)
    raise "Expected Hash, got #{yaml.raw.class}" unless yaml.raw.is_a?(Hash(YAML::Any, YAML::Any))
    raise %(No key "name:" found in table definition) unless yaml.as_h.has_key?("name")
    Table.new(yaml["name"].as_s).tap do |table|
      yaml["columns"].as_a.each do |column|
        table.columns << CQL::Column.from_yaml(column.to_yaml)
      end
      if yaml["constraints"]?
        yaml["constraints"].as_a.each do |constraint|
          table.constraints << TableConstraint.from_yaml(constraint.to_yaml)
        end
      end
    end
  end

  # Add a CQL::Column definition
  def column(column : Column)
    @columns << column
    self
  end

  # Add a new CQL::Column based on the arguments
  def column(*args, **options)
    column(Column.new(*args, **options))
    self
  end

  struct TableConstraint
    YAML.mapping(
      name: String,
      unique: Array(String)?
    )

    def initialize(@name : String, @unique : Array(String) = [] of String)
    end
  end
end
