Sequel.migration do
  change do
    alter_table(:hidden_lists) do
      drop_column :user_id
      add_foreign_key :user_id, :users
    end
  end
end