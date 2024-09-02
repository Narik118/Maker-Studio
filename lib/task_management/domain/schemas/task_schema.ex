defmodule TaskManagement.Domain.Schemas.TaskSchema do
  @moduledoc """
  Module to define task schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @valid_statuses ["To Do", "In Progress", "Done"]

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :due_date, :utc_datetime
    field :status, :string
    belongs_to :user, TaskManagement.Domain.Schemas.UserSchema, type: :binary_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for a task.
  """
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :due_date, :status, :user_id])
    |> validate_required([:title, :description, :due_date, :status, :user_id])
    |> validate_inclusion(:status, @valid_statuses)
    |> foreign_key_constraint(:user_id, name: :tasks_user_fkey)
  end
end
