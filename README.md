[![Build Status](https://travis-ci.org/aisrael/cql.svg?branch=develop)](https://travis-ci.org/aisrael/cql)

# cql

CQL is a SQL toolkit for Crystal, inspired by Ruby's [Sequel](https://github.com/jeremyevans/sequel) and Java's [jOOQ](https://www.jooq.org).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  cql:
    github: aisrael/cql
```

## Usage

```crystal
require "cql"
```

### Connect to a PostgreSQL database

```crystal
db = CQL.postgres(DATABASE_URL)
```

Or, if `$DATABASE_URL` is set, just

```crystal
db = CQL.database
```

### Using `CQL::Command` objects

#### Create Table

```crystal
create_table = CQL::Command::CreateTable.new(db, "foobar")
create_table.column("id", CQL::SERIAL, null: false, primary_key: true)
create_table.column("name", CQL::VARCHAR, size: 40, null: false, unique: true)
create_table.exec
```

#### Insert

```crystal
insert = CQL::Command::Insert.new(db, "users").column("name")
insert.to_s # => INSERT INTO users (name) VALUES ($1)
insert.exec("test") # => exec("INSERT INTO users (name) VALUES ($1)", "test")
```

#### Delete

```crystal
delete = CQL::Command::Delete.new(db, "users").where(name: "test")
delete.to_s # => DELETE FROM users WHERE name = $1
delete.exec # => exec(DELETE FROM users WHERE name = $1, "test")
```

### Using `CQL::Database`

#### Create Table

```crystal
db.create_table("foobar").column("id", "INTEGER").exec
```

#### Insert

```crystal
db.insert("foobar").column("id").exec(123)
```

#### Count

```crystal
db.count("users").as_i64
```

### Using `CQL::Schema` (see

```crystal
users_table = CQL::Schema.new(CQL.postgres, User, "users",
  id: Int32,
  name: String
)

users_table.count                 # => 0
users_table.insert.values("test") # => exec("INSERT INTO users (name) VALUES ($1)",
users_table.count                 # => 1

users = users_table.all           # => query_all("SELECT id, name FROM users")
users.first.id                    # => 1
users.first.name                  # => "test"

user_id_1 = users_table.where(id: 1).one
user_id_1.id                      # => 1
user_id_1.name                    # => "test"

users_named_test = users_table.where(name: "test").all
users_named_test.first.id         # => 1
users_named_test.first.name       # => "test"

users_table.where(id: 1).delete   # => 1
users_table.count                 # => 0
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/aisrael/cql/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [aisrael](https://github.com/aisrael) Alistair A. Israel - creator, maintainer
