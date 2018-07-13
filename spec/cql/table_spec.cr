require "yaml"
require "../spec_helper"

describe CQL::Table do
  it "can be created from YAML" do
    text = <<-YAML
    ---
    create_table:
      name: channels
      columns:
      - name: id
        type: SERIAL
      - name: name
        type: varchar
        size: 40
        "null": false
      - name: activated
        type: BOOLEAN
        "null": false
        default: "false"
    YAML
    yaml = YAML.parse(text)
    table = CQL::Table.from_yaml(yaml["create_table"])
    columns = table.columns
    columns.size.should eq(3)
    columns[0].name.should eq("id")
    columns[0].type.should eq(CQL::SERIAL)
    columns[1].name.should eq("name")
    columns[1].type.should eq(CQL::VARCHAR)
    columns[1].size.should eq(40)
    columns[1].null.should_not be_nil
    columns[1].null.should be_false
    columns[2].name.should eq("activated")
    columns[2].type.should eq(CQL::BOOLEAN)
  end
  it "supports table_constraints" do
    text = <<-YAML
    ---
    create_table:
      name: users
      columns:
      - name: property_id
        type: INTEGER
        null: false
      - name: username
        type: varchar
        size: 40
        null: false
      constraints:
      - name: uq_users_property_username
        unique:
        - property_id
        - username
    YAML
    yaml = YAML.parse(text)
    table = CQL::Table.from_yaml(yaml["create_table"])
    columns = table.columns
    columns.size.should eq(2)
    columns[0].name.should eq("property_id")
    columns[0].type.should eq(CQL::INTEGER)
    columns[1].name.should eq("username")
    columns[1].type.should eq(CQL::VARCHAR)
    constraints = table.constraints
    constraints.size.should eq(1)
    constraints[0].name.should eq("uq_users_property_username")
    constraints[0].unique.should_not be_nil
    unique = constraints[0].unique.not_nil!
    unique.size.should eq(2)
    unique[0].should eq("property_id")
    unique[1].should eq("username")
  end
end
