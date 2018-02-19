![Build status](https://travis-ci.org/aisrael/cql.svg?branch=develop)

# cql

CQL is a SQL toolkit for Crystal, inspired by Sequel for Ruby.

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
db = DB.postgres(DATABASE_URL)
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
