require "../spec_helper"

describe CQL::Column do
  describe "#to_s" do
    it "works" do
      column = CQL::Column.new("id", "SERIAL")
      column.to_s.should eq("id SERIAL")
    end
  end
end
