defmodule TaskManagementWeb.User.UserController do
  @moduledoc """
  controller to handle requests related to user
  """
  use TaskManagementWeb, :controller

  alias TaskManagementWeb.Auth.TokenClient
  alias TaskManagement.Domain.Interactors.UserInteractor
  alias TaskManagementWeb.ChangesetErrorTranslator

  @doc """
  creates a new user
  """
  def create(%{body_params: %{"name" => name, "email" => email}} = conn, _params) do
    attrs = %{
      name: name,
      email: email
    }

    with {:ok, user} <- UserInteractor.insert_user(attrs),
         token <- TokenClient.generate_new_token(user.id) do
      resp = %{message: "user successfully created", user_id: user.id, user: attrs, token: token}

      conn
      |> put_status(201)
      |> json(resp)
    else
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
