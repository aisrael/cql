require "./column"

class CQL::Table
  property :name
  getter :columns
  @columns = [] of Column

  # Defines a new SQL Table with the given name
  def initialize(@name : String)
  end

  def self.from_yaml(yaml)
    raise "Expected Hash, got #{yaml.raw.class}" unless yaml.raw.is_a?(Hash(YAML::Type, YAML::Type))
    raise %(No key "name:" found in table definition) unless yaml.as_h.has_key?("name")
    Table.new(yaml["name"].as_s).tap do |table|
      yaml["columns"].each do |column|
        table.columns << CQL::Column.from_yaml(column.to_yaml)
      end
    end
  end

  # Add a CQL::Column definition
  def column(column : Column)
    @columns << column
  end

  # Add a new CQL::Column based on the arguments
  def column(*args, **options)
    column(Column.new(*args, **options))
  end
end
