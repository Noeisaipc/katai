defmodule KataiWeb.Plug.SignatureValidation do
  @moduledoc """
  Reads and validates headers from requests.
  """
  import Plug.Conn
  require Logger
  alias PrimeTime.CardHolders

  @spec init(any()) :: any()
  def init(opts), do: opts

  def call(conn, _opts) do
    card_holder_id = conn.private.guardian_default_claims["sub"]

    with {:ok, card_holder} <- CardHolders.get_card_holder_by_id(card_holder_id),
         {:ok, public_key} <- fetch_public_key_from_user(card_holder),
         {:ok, "valid"} <-
           validate_hash_from_conn(
             conn.assigns[:time_stamp],
             conn.host,
             conn.request_path,
             List.first(conn.assigns.raw_body) || "",
             conn.assigns[:recv_msg_serialized]
           ),
         {:ok, _keysing} <-
           validate_signature(
             conn.assigns[:signature],
             conn.assigns[:recv_msg_serialized],
             public_key
           ) do
      conn
    else
      {:error, _reason} ->
        conn
        |> send_resp(400, Jason.encode!(%{message: "Servicio en Mantenimiento"}))
        |> halt
    end
  end

  @spec validate_hash_from_conn(String.t(), String.t(), String.t(), String.t(), String.t()) ::
          {:ok, String.t()} | {:error, String.t()}
  def validate_hash_from_conn(time_stamp, host, path, body, hash_from_header) do
    conn_hash =
      :crypto.hash(:sha256, "#{time_stamp}#{host}#{path}#{body}")
      |> Base.encode64()

    case conn_hash == hash_from_header do
      true ->
        {:ok, "valid"}

      false ->
        {:error, "invalid request"}
    end
  end

  @spec fetch_public_key_from_user(atom | %{:public_key => any, optional(any) => any}) ::
          {:error, any} | {:ok, struct} | {:error | :exit | :throw | {:EXIT, pid}, any, any}
  def fetch_public_key_from_user(user) do
    bin_pub_key =
      "-----BEGIN RSA PUBLIC KEY-----\n#{user.public_key}\n-----END RSA PUBLIC KEY-----\n"

    ExPublicKey.loads(bin_pub_key)
  end

  @spec validate_signature(any, any, any) ::
          :ok
          | {:error, any}
          | {:ok, boolean}
          | {:error | :exit | :throw | {:EXIT, pid}, any, any}
  def validate_signature(signature, body, public_key) do
    try do
      decode_signature = Base.decode64!(signature)
      ExPublicKey.verify(body, decode_signature, public_key)
    rescue
      e in KeyError -> IO.puts("Llave no valida" <> e.message)
    end
  end
end
