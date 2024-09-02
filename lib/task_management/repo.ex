defmodule TaskManagement.Repo do
  use Ecto.Repo,
    otp_app: :task_management,
    adapter: Ecto.Adapters.SQLite3

  @doc """
  Don't raise on insert error.
  """
  def try_insert(changeset) do
    try do
      insert(changeset)
    rescue
      e -> {:error, e}
    end
  end

  @doc """
  Don't raise on update error.
  """
  def try_update(changeset) do
    try do
      update(changeset)
    rescue
      e -> {:error, e}
    end
  end

  @doc """
  Don't raise on delete error.
  """
  def try_delete(obj) do
    try do
      delete(obj)
    rescue
      e -> {:error, e}
    end
  end

  @doc """
  Return error one one.
  """
  def try_one(query) do
    try do
      result = one(query)

      if is_nil(result) do
        {:error, :not_found}
      else
        {:ok, result}
      end
    rescue
      e -> {:error, e}
    end
  end
end
