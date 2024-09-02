defmodule TaskManagement.Repo.Migrations.Tasks do
  use Ecto.Migration

  def up do
    create_tasks_table()
  end

  def down do
    drop_if_exists table(:tasks)
  end

  def create_tasks_table do
    create_if_not_exists table(:tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true, autogenerate: true
      add :title, :string
      add :description, :text
      add :due_date, :utc_datetime
      add :status, :string
      add :user_id, references(:users, type: :binary_id), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:tasks, [:user_id])
  end
end
