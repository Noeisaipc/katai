defmodule KataiWeb.Plug.HeadersValidation do
  @moduledoc """
  Reads and validates headers from requests.
  """
  import Plug.Conn

  @spec init(any()) :: any()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def call(conn, _opts) do
    result =
      with {:ok, conn} <- read_header(conn, "signature"),
           {:ok, conn} <- read_header(conn, "recv_msg_serialized"),
           {:ok, conn} <- read_header(conn, "time_stamp") do
        {:ok, conn}
      end

    case result do
      {:ok, conn} ->
        conn

      {:error, reason} ->
        conn
        |> send_resp(400, reason)
        |> halt
    end
  end

  defp read_header(conn, header) do
    case get_req_header(conn, header) do
      [] ->
        {:error, "El header #{header} es requerido"}

      [header_value] ->
        case header_value do
          nil ->
            {:error, "El header #{header} es requerido"}

          "" ->
            {:error, "El header #{header} es requerido"}

          _value ->
            conn = assign(conn, String.to_atom(header), header_value)
            {:ok, conn}
        end
    end
  end
end
