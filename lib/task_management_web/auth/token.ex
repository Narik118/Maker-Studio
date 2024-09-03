defmodule TaskManagementWeb.Auth.Token do
  @moduledoc """
  Token module for JWT.
  """
  use Joken.Config

  def token_config, do: default_claims(default_exp: 10 * 365 * 24 * 60 * 60)
end
