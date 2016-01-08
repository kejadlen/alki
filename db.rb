require "sequel"

Sequel::Model.plugin :timestamps, update_on_create: true

DB = Sequel.connect(ENV.fetch("DATABASE_URL"))
DB.extension :pg_json
