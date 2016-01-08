task :console do
  require "dotenv"
  Dotenv.load(".private.envrc")

  require_relative "db"
  require_relative "trello"
  include Alki

  trello = Trello::Authed.new(api_key: ENV["TRELLO_KEY"],
                              api_secret: ENV["TRELLO_SECRET"],
                              access_token: ENV["ACCESS_TOKEN"],
                              access_token_secret: ENV["ACCESS_TOKEN_SECRET"])

  require "pry"
  binding.pry
end

namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    require_relative "db"

    Sequel.extension :migration

    if args[:version]
      puts "Migrating to version #{args[:version]}"
      Sequel::Migrator.run(Alki::DB, "db/migrations", target: args[:version].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(Alki::DB, "db/migrations")
    end

    Alki::DB.extension :schema_dumper
    File.write("db/schema.rb", Alki::DB.dump_schema_migration(same_db: true).gsub(/^\s+$/, ''))
  end
end

require "rake/testtask"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/test_*.rb"]
  t.verbose = true
end

task default: :test