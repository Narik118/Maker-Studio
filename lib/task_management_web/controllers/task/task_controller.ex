defmodule TaskManagementWeb.Task.TaskController do
  @moduledoc """
  controller to handle all tasks related requests
  """

  use TaskManagementWeb, :controller

  alias TaskManagement.Domain.Interactors.TaskInteractor
  alias TaskManagementWeb.ChangesetErrorTranslator

  @doc """
  Create a new task for the specified user
  """
  def create(
        conn,
        %{
          "description" => description,
          "due_date" => due_date,
          "status" => status,
          "title" => title,
          "user_id" => user_id
        } = _params
      ) do
    params = %{
      description: description,
      due_date: due_date,
      status: status,
      title: title,
      user_id: user_id
    }

    with true <- user_authorized?(conn, user_id),
         {:ok, task} <- TaskInteractor.insert_task(params) do
      resp = %{message: "Task successfully added", task_id: task.id}

      conn
      |> put_status(201)
      |> json(resp)
    else
      false ->
        resp = %{error: "Unauthorized or Invalid token"}

        conn
        |> put_status(403)
        |> json(resp)

      {:error, %Ecto.Changeset{} = error} ->
        resp = %{error: ChangesetErrorTranslator.translate_error(error)}

        conn
        |> put_status(400)
        |> json(resp)
    end
  end

  def create(conn, _params) do
    resp = %{error: "Invalid request body."}

    conn
    |> put_status(400)
    |> json(resp)
  end

  @doc """
  Retrieve all tasks for the specified user
  """
  def get_all_tasks(conn, %{"user_id" => user_id} = _params) do
    with true <- user_authorized?(conn, user_id),
         tasks when is_list(tasks) <- TaskInteractor.get_users_tasks(user_id) do
      if length(tasks) > 1 do
        resp = %{message: "#{length(tasks)} tasks found for the user", tasks: tasks}

        conn
        |> put_status(200)
        |> json(resp)
      end
    else
      [] ->
        resp = %{message: "No tasks found for the user #{user_id}"}

        conn
        |> put_status(404)
        |> json(resp)

      false ->
        resp = %{error: "Unauthorized or Invalid token"}

        conn
        |> put_status(403)
        |> json(resp)
    end
  end

  @doc """
  Retrieve a specific task for the specified user
  """
  def get_task(conn, %{"user_id" => user_id, "task_id" => task_id} = _params) do
    with true <- user_authorized?(conn, user_id),
         {:ok, task} <- TaskInteractor.get_task_by_id(user_id, task_id) do
      resp_task = %{
        "id" => task.id,
        "title" => task.title,
        "description" => task.description,
        "status" => task.status,
        "due_date" => task.due_date,
        "user_id" => task.user_id
      }

      resp = %{message: resp_task}

      conn
      |> put_status(200)
      |> json(resp)
    else
      {:error, :not_found} ->
        resp = %{error: "Requested task could not be found. Please recheck user id and task id"}

        conn
        |> put_status(401)
        |> json(resp)

      false ->
        resp = %{error: "Unauthorized or Invalid token"}

        conn
        |> put_status(403)
        |> json(resp)
    end
  end

  @doc """
  Update a specific task for the specified user
  """
  def update_task(
        conn,
        %{
          "user_id" => user_id,
          "task_id" => task_id,
          "title" => title,
          "description" => description,
          "due_date" => due_date,
          "status" => status
        } = _params
      ) do
    updated_task = %{
      "id" => task_id,
      "title" => title,
      "description" => description,
      "status" => status,
      "due_date" => due_date,
      "user_id" => user_id
    }

    with true <- user_authorized?(conn, user_id),
         {:ok, updated_task} <- TaskInteractor.update_task(user_id, task_id, updated_task) do
      keys_to_drop = [:user, :__meta__, :inserted_at, :updated_at]
      updated_task_formatted = Map.from_struct(updated_task) |> Map.drop(keys_to_drop)
      resp = %{message: "Task successfully updated", updated_task: updated_task_formatted}

      conn
      |> put_status(200)
      |> json(resp)
    else
      {:error, :not_found} ->
        resp = %{error: "Invalid task id or user id"}

        conn
        |> put_status(400)
        |> json(resp)

      {:error, :unknown_error} ->
        resp = %{error: "Unknown Error"}

        conn
        |> put_status(400)
        |> json(resp)

      false ->
        resp = %{error: "Unauthorized or Invalid token"}

        conn
        |> put_status(403)
        |> json(resp)
    end
  end

  def update_task(conn, _params) do
    resp = %{error: "Invalid request body."}

    conn
    |> put_status(400)
    |> json(resp)
  end

  @doc """
  delete a specific task for the specified user
  """
  def delete_task(conn, %{"user_id" => user_id, "task_id" => task_id} = _params) do
    with true <- user_authorized?(conn, user_id),
         {:ok, task} <- TaskInteractor.delete_task(user_id, task_id) do
      keys_to_drop = [:user, :__meta__, :inserted_at, :updated_at]
      task = Map.from_struct(task)
      deleted_task = Map.drop(task, keys_to_drop)
      resp = %{messsage: "Task deleted successfully", deleted_task: deleted_task}

      conn
      |> put_status(200)
      |> json(resp)
    else
      {:error, error} ->
        resp = %{error: error}

        conn
        |> put_status(400)
        |> json(resp)

      false ->
        resp = %{error: "Unauthorized or Invalid token"}

        conn
        |> put_status(403)
        |> json(resp)
    end
  end

  def delete_task(conn, _params) do
    resp = %{error: "Ivalid request"}

    conn
    |> put_status(400)
    |> json(resp)
  end

  defp user_authorized?(conn, user_id) do
    case Map.get(conn.assigns, :user_id) do
      {:ok, user_id_token} -> user_id_token == user_id
      _ -> false
    end
  end
end
