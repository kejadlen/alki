Sequel.migration do
  change do
    alter_table(:users) do
      add_column :trello_id, String
    end
  end
end
