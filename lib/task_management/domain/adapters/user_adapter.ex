defmodule TaskManagement.Domain.Adapters.UserAdapter do
  @moduledoc """
  Module to define functions to User Table DB operations
  """
  import Ecto.Query
  alias TaskManagement.Repo
  alias TaskManagement.Domain.Schemas.UserSchema

  @doc """
  Inserts a new user
  """
  def insert_user(attrs) do
    %UserSchema{}
    |> UserSchema.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Get's a user by id
  """
  def get_user_by_id(user_id) do
    UserSchema
    |> where([u], u.id == ^user_id)
    |> Repo.try_one()
  end

  @doc """
  Get's a user by email
  """
  def get_user_by_email(email) do
    UserSchema
    |> where([u], u.email == ^email)
    |> Repo.try_one()
  end
end
