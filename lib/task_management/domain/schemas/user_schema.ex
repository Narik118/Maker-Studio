defmodule TaskManagement.Domain.Schemas.UserSchema do
  @moduledoc """
  Module to define schema for users
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @mail_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  schema "users" do
    field :name, :string
    field :email, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  create user changeset
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_email(:email)
    |> unique_constraint([:email])
  end

  @doc """
  function to check if the email is in valid format
  """
  def validate_email(changeset, field) do
    changeset
    |> validate_format(field, @mail_regex)
  end
end
