defmodule TaskManagementWeb.Auth.TokenClient do
  @moduledoc """
  Module to verify and generate JWT auth tokens.
  """
  alias TaskManagementWeb.Auth.Token

  @doc """
  This function generates a new token for the given user.
  The token contains the user's ID.
  The token is signed with a secret key.
  Returns the token.
  """
  def generate_new_token(user_id) do
    claims = %{"user_id" => user_id}
    {:ok, token, _claims} = Token.generate_and_sign(claims)
    token
  end

  @doc """
  This function gets the user ID from the given JWT token.
  The token must be valid and signed with the secret key.
  Returns the user ID if the token is valid
  Or returns nil if the token is invalid.
  """
  def get_user_id_by_jwt_token(token) do
    case Token.verify_and_validate(token) do
      {:ok, claims} ->
        {:ok, Map.get(claims, "user_id")}

      _ ->
        nil
    end
  end
end
