defmodule TaskManagementWeb.Plug.UserAuth do
  @moduledoc """
    Module for making user authentication.
  """
  import Plug.Conn
  use TaskManagementWeb, :controller

  alias TaskManagementWeb.Auth.TokenClient

  def get_auth_token(user, _params \\ %{}), do: TokenClient.generate_new_token(user)

  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user_id = user_token && TokenClient.get_user_id_by_jwt_token(user_token)
    assign(conn, :user_id, user_id)
  end

  defp get_bearer_token([{"authorization", "Bearer undefined"} | _rest]), do: nil
  defp get_bearer_token([{"authorization", token} | _rest]), do: String.slice(token, 7, 100_000)
  defp get_bearer_token([_h | rest]), do: get_bearer_token(rest)
  defp get_bearer_token([]), do: nil

  defp ensure_user_token(%Plug.Conn{req_headers: headers} = conn),
    do: {get_bearer_token(headers), conn}

  defp ensure_user_token(conn), do: {nil, conn}
end
