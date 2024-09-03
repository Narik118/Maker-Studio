defmodule TaskManagement.Domain.Interactors.UserInteractor do
  @moduledoc """
  Entry point for all user operations
  """
  alias TaskManagement.Domain.Adapters.UserAdapter

  defdelegate insert_user(attrs), to: UserAdapter
  defdelegate get_user_by_id(user_id), to: UserAdapter
  defdelegate get_user_by_email(email), to: UserAdapter
end
