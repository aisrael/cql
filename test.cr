require "uri"

uri = URI.parse("postgres://postgres:secret@localhost/cql_test")
puts uri.scheme
