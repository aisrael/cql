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
    column = CQL::Column.new("refrences_other_code", CQL::CHAR, size: 8, references: "other(code)")
    column.to_s.should eq("refrences_other_code CHAR(8) REFERENCES other(code)")
  end
end
