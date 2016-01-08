Sequel.migration do
  change do
    alter_table(:users) do
      set_column_allow_null :access_token
      set_column_allow_null :access_token_secret
    end
  end
end
