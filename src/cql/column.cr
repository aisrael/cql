require "yaml"

struct CQL::Column
  YAML.mapping(
    name: String,
    type: CQL::ColumnType,
    size: Int32?,
    null: Bool?,
    primary_key: Bool?,
    unique: Bool?,
    default: CQL::Type?,
    references: String?
  )

  def initialize(@name : String,
                 @type : CQL::ColumnType,
                 @size : Int32? = nil,
                 @null : Bool? = nil,
                 @primary_key : Bool? = nil,
                 @unique : Bool? = nil,
                 @default : CQL::Type? = nil,
                 @references : String? = nil)
  end

  def to_s(io)
    parts = [@name]
    case @type
    when CHAR, VARCHAR
      if @size
        parts << "#{@type}(#{@size})"
      end
    else
      parts << @type.to_s
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
    unless @default.nil?
      parts << "DEFAULT #{@default}"
    end
    references = @references
    unless references.nil?
      fk = references =~ /\(.+\)$/ ? references : references + "(id)"
      parts << "REFERENCES #{fk}"
    end
    io << parts.join(" ")
  end
end
