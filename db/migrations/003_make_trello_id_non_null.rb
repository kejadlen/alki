Sequel.migration do
  change do
    alter_table(:users) do
      set_column_not_null :trello_id
    end
  end
end
