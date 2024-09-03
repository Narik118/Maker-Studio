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
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  create user changeset
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:email, :password])
    |> validate_email(:email)
    |> unique_constraint([:email])
    |> hash_password()
  end

  @doc """
  function to check if the email is in valid format
  """
  def validate_email(changeset, field) do
    changeset
    |> validate_format(field, @mail_regex)
  end

  defp hash_password(changeset) do
    if changeset |> get_change(:password) do
      changeset
      |> put_change(:password_hash, Argon2.hash_pwd_salt(get_change(changeset, :password)))
    else
      changeset
    end
  end
end
