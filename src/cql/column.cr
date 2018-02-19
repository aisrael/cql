struct CQL::Column
  getter :name, :type, :size, :null, :primary_key, :unique, :references
  def initialize(@name : String,
                 @type : String,
                 @size : Int32? = nil,
                 @null : Bool? = nil,
                 @primary_key : Bool? = nil,
                 @unique : Bool? = nil,
                 @references : String? = nil)
  end

  def to_s(io)
    parts = [@name]
    case @type
    when "CHAR", "VARCHAR"
      if @size
        parts << "#{@type}(#{@size})"
      end
    else
      parts << @type
    end
    unless @null.nil?
      parts << "NOT" unless @null
      parts << "NULL"
    end
    unless @primary_key.nil?
      parts << "PRIMARY KEY" if @primary_key
    end
    unless @unique.nil?
      parts << "UNIQUE" if @unique
    end
    unless @references.nil?
      parts << "REFERENCES #{@references}"
    end
    io << parts.join(" ")
  end
end
