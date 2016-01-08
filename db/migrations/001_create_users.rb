Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id

      String :access_token, null: false
      String :access_token_secret, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
