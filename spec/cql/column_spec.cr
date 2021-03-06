require "../spec_helper"

describe CQL::Column do
  it "works" do
    column = CQL::Column.new("id", CQL::SERIAL)
    column.to_s.should eq("id SERIAL")
  end
  it "handles size for CHAR" do
    column = CQL::Column.new("eight", CQL::CHAR, size: 8)
    column.to_s.should eq("eight CHAR(8)")
  end
  it "handles size for VARCHAR" do
    column = CQL::Column.new("eight", CQL::VARCHAR, size: 8)
    column.to_s.should eq("eight VARCHAR(8)")
  end
  it "handles not null" do
    column = CQL::Column.new("required", CQL::INTEGER, null: false)
    column.to_s.should eq("required INTEGER NOT NULL")
  end
  it "handles null" do
    column = CQL::Column.new("nullable", CQL::INTEGER, null: true)
    column.to_s.should eq("nullable INTEGER NULL")
  end
  it "handles not unique" do
    column = CQL::Column.new("notunique", CQL::INTEGER, unique: false)
    column.to_s.should eq("notunique INTEGER")
  end
  it "handles unique" do
    column = CQL::Column.new("unique", CQL::INTEGER, unique: true)
    column.to_s.should eq("unique INTEGER UNIQUE")
  end
  it "handles not primary key" do
    column = CQL::Column.new("notpk", CQL::INTEGER, primary_key: false)
    column.to_s.should eq("notpk INTEGER")
  end
  it "handles primary key" do
    column = CQL::Column.new("pk", CQL::INTEGER, primary_key: true)
    column.to_s.should eq("pk INTEGER PRIMARY KEY")
  end
  it "handles references" do
    column = CQL::Column.new("references_other_code", CQL::CHAR, size: 8, references: "other(code)")
    column.to_s.should eq("references_other_code CHAR(8) REFERENCES other(code)")
  end
  it "handles references and defaults to table(id)" do
    column = CQL::Column.new("references_other_id", CQL::INTEGER, references: "other")
    column.to_s.should eq("references_other_id INTEGER REFERENCES other(id)")
  end
  describe "#from_yaml" do
    it "can handle BOOLEAN types" do
      s = <<-YAML
      name: disabled
      type: BOOLEAN
      YAML
      column = CQL::Column.from_yaml(s)
      column.name.should eq("disabled")
      column.type.should eq(CQL::BOOLEAN)
    end
    it "can handle not null BOOLEAN types with defaults" do
      s = <<-YAML
      name: disabled
      type: BOOLEAN
      "null": false
      default: "false"
      YAML
      column = CQL::Column.from_yaml(s)
      column.name.should eq("disabled")
      column.type.should eq(CQL::BOOLEAN)
      column.null.should be_false
      column.default.should eq("false")
    end
    it "can handle references" do
      s = <<-YAML
      name: property_id
      type: INTEGER
      null: false
      references: properties
      YAML
      column = CQL::Column.from_yaml(s)
      column.name.should eq("property_id")
      column.type.should eq(CQL::INTEGER)
      column.null.should be_false
      column.references.should eq("properties")
    end
  end
end
