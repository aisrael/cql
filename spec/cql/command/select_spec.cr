require "../../spec_helper"

describe CQL::Command::Select do
  it "can generate proper SQL" do
    sel = CQL::Command::Select.new(CQL.postgres, "users")
      .columns("id", "name")
      .where(id: 1)
    sel.to_s.should eq("SELECT id, name FROM users WHERE id = $1")
  end
  it "works" do
    db = CQL.connect
    db.exec("DROP TABLE IF EXISTS users;")
    db.create_table("users")
      .column("id", CQL::SERIAL, null: false, primary_key: true)
      .column("name", CQL::VARCHAR, null: false, size: 40).exec
    db.insert("users").columns("name").exec("test")

    sel = CQL::Command::Select.new(CQL.postgres, "users")
      .columns("id", "name")
      .where(id: 1)
    user = sel.one do |rs|
      id, name = rs.read(Int32, String)
      {id: id, name: name}
    end
    user[:id].should eq(1)
    user[:name].should eq("test")
  ensure
    CQL.connect.drop_table("users")
  end
end
