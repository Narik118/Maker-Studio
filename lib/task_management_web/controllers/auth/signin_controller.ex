defmodule TaskManagementWeb.Auth.SigninController do
  @moduledoc """
  controller to handle requests to signin. sends user id and token as response
  """

  use TaskManagementWeb, :controller

  alias TaskManagement.Domain.Interactors.UserInteractor
  alias TaskManagementWeb.Auth.TokenClient

  @doc """
  function to handle signin request. returns user id and password for a valid user
  """
  def signin(%{body_params: %{"email" => email, "password" => password}} = conn, _params) do
    case UserInteractor.get_user_by_email(email) do
      {:ok, user} ->
        if Argon2.verify_pass(password, user.password_hash) do
          token = TokenClient.generate_new_token(user.id)

          resp = %{user_id: user.id, token: token}

          conn
          |> put_status(200)
          |> json(resp)
        else
          resp = %{error: "Invalid password."}

          conn
          |> put_status(400)
          |> json(resp)
        end

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def signin(conn, _params) do
    resp = %{error: "Invalid request body."}

    conn
    |> put_status(400)
    |> json(resp)
  end
end
