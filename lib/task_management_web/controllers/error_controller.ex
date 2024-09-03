defmodule TaskManagementWeb.ErrorController do
  @moduledoc """
  This controller hadnles all the undeifined router
  """

  use TaskManagementWeb, :controller

  @doc """
  throws a 404 if a routh is unmatched
  """
  def not_found(conn, _params) do
    conn
    |> put_status(404)
    |> json("No route found.")
  end
end
