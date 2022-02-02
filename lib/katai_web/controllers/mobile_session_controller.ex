defmodule KataiWeb.MobileSessionController do
  use KataiWeb, :controller
  alias KataiWeb.Guardian

  def sign_in(conn, %{"email" => email, "password" => password, "public_key" => public_key}) do
    case Katai.Accounts.login(email, password) do
      {:ok, user} ->
        user = Katai.Accounts.register_public_key(user, public_key)
        {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
        conn
        |> render("sign_in.json",
          jwt: jwt
        )
      {:error, _no_found} ->
        conn
        |> put_status(401)
        |> render("sign_in_error.json", message: "Email o Contraseña Incorrecta")
    end
  end

  def test_sign(conn, _params) do
    conn
    |> render("sign_test.json",
      message: "digital_sign_is_working"
    )
  end

  def sign_out(conn, _params) do
    jwt = Guardian.Plug.current_token(conn)
    Guardian.revoke(jwt)
    conn
    |> put_status(200)
    |> render("sign_out.json",
      message: "sign_out"
    )
  end
end
