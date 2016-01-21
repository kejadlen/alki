Sequel.migration do
  change do
    create_table(:hidden_lists) do
      primary_key :id

      Integer :user_id, null: false
      Integer :board_id, null: false
      Integer :list_id, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
