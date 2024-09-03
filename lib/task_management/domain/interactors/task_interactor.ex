defmodule TaskManagement.Domain.Interactors.TaskInteractor do
  @moduledoc """
  Entry point for all tasks realted operations
  """

  alias TaskManagement.Domain.Adapters.TaskAdapter

  defdelegate insert_task(attrs), to: TaskAdapter
  defdelegate get_task_by_id(user_id, task_id), to: TaskAdapter
  defdelegate get_users_tasks(user_id), to: TaskAdapter
  defdelegate update_task(user_id, task_id, attrs), to: TaskAdapter
  defdelegate delete_task(user_id, task_id), to: TaskAdapter
end
