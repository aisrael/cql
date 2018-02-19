require "pg"
require "spec"
require "../src/cql"

unless ENV.has_key?("DATABASE_URL")
  STDERR.puts "$DATABASE_URL not defined"
  exit 1
end

DATABASE_URL = ENV["DATABASE_URL"]
puts "$DATABASE_URL => #{DATABASE_URL}"

unless path = URI.parse(DATABASE_URL).path
  STDERR.puts %(Cannot parse path component of "#{DATABASE_URL}"!)
  exit 1
end

database_name = path.starts_with?("/") ? path[1..-1] : path

url_without_path = ENV["DATABASE_URL"][0..-path.size-1]

# TODO MySQL?
DB.open(url_without_path) do |db|
  db.exec("DROP DATABASE IF EXISTS #{database_name};")
  db.exec("CREATE DATABASE #{database_name};")
end
