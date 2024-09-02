defmodule TaskManagement.Domain.Adapters.TaskAdapter do
  @moduledoc """
  Adapter to define all tasks realted operations
  """

  import Ecto.Query
  alias TaskManagement.Repo
  alias TaskManagement.Domain.Schemas.TaskSchema

  @doc """
  inserts a new task
  """
  def insert_task(attrs) do
    %TaskSchema{}
    |> TaskSchema.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  get user's task by task id
  """
  def get_task_by_id(user_id, task_id) do
    TaskSchema
    |> where([u], u.user_id == ^user_id and u.id == ^task_id)
    |> Repo.try_one()
  end

  @doc """
  update user's task by task id
  """
  def update_task_by_id(user_id, task_id, attrs) do # update_task as fun name
    with {:ok, task} <- get_task_by_id(user_id, task_id),
         {:ok, %TaskSchema{user_id: ^user_id}} <- update_task(task, attrs) do
      {:ok, :updated} #return updated task
    else
      {:error, :not_found} ->
        {:error, :not_found}

      {:error, _error} ->
        {:error, :unknown_error}
    end
  end

  defp update_task(task, attrs) do
    task
    |> TaskSchema.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  get all tasks of a user
  """
  @spec get_users_tasks(any()) :: any()
  def get_users_tasks(user_id) do
    TaskSchema
    |> where([u], u.user_id == ^user_id)
    |> select([u], %{
      id: u.id,
      title: u.title,
      status: u.status,
      description: u.description,
      due_date: u.due_date
    })
    |> Repo.all()
  end

  def delete_task_by_id(task_id) do #user_id and task_id and use with
    case Repo.get(TaskSchema, task_id) do
      nil ->
        {:error, :not_found}

      task ->
        case Repo.delete(task) do
          {:ok, _deleted_task} ->
            {:ok, task}

          {:error, _changeset} ->
            {:error, :delete_failed}
        end
    end
  end
end
