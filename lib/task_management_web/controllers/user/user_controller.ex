defmodule TaskManagementWeb.User.UserController do
  @moduledoc """
  controller to handle requests related to user
  """
  use TaskManagementWeb, :controller

  alias TaskManagement.Domain.Interactors.UserInteractor
  alias TaskManagementWeb.ChangesetErrorTranslator

  @doc """
  creates a new user
  """
  def create(
        %{body_params: %{"name" => name, "email" => email, "password" => password}} = conn,
        _params
      ) do
    attrs = %{
      name: name,
      email: email,
      password: password
    }

    case UserInteractor.insert_user(attrs) do
      {:ok, _user} ->
        resp = %{message: "user successfully created"}

        conn
        |> put_status(201)
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
end
