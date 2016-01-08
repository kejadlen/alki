Sequel.migration do
  change do
    create_table(:schema_info) do
      column :version, "integer", :default=>0, :null=>false
    end

    create_table(:users) do
      primary_key :id
      column :access_token, "text", :null=>false
      column :access_token_secret, "text", :null=>false
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
  end
end
