Sequel.migration do
  change do
    create_table(:actions) do
      primary_key :id

      json :raw

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
