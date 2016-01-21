Sequel.migration do
  change do
    create_table(:actions) do
      primary_key :id
      column :raw, "json"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end

    create_table(:schema_info) do
      column :version, "integer", :default=>0, :null=>false
    end

    create_table(:users) do
      primary_key :id
      column :access_token, "text"
      column :access_token_secret, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      column :trello_id, "text", :null=>false
    end

    create_table(:hidden_lists) do
      primary_key :id
      column :board_id, "integer", :null=>false
      column :list_id, "integer", :null=>false
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      foreign_key :user_id, :users, :key=>[:id]
    end
  end
end
