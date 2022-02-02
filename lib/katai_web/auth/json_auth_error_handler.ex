defmodule KataiWeb.JsonAuthErrorHandler do
  @moduledoc """
  Guardian error handler for api
  """
  use KataiWeb, :router

  @spec auth_error(Plug.Conn.t(), any, any) :: Plug.Conn.t()
  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{message: to_string(type)})
    send_resp(conn, 401, body)
  end
end
