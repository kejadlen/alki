Sequel.migration do
  change do
    alter_table(:hidden_lists) do
      set_column_type(:board_id, 'text')
      set_column_type(:list_id, 'text')
    end
  end
end