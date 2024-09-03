defmodule TaskManagement.Repo.Migrations.Users do
  use Ecto.Migration

  def up do
    create_users_table()
  end

  def down do
    drop_if_exists table(:users)
  end

  def create_users_table() do
    create_if_not_exists table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true, autogenerate: true
      add :name, :string
      add :email, :string
      add :password_hash, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:users, [:email])
  end
end
