defmodule Katai.Repo do
  use Ecto.Repo,
    otp_app: :katai,
    adapter: Ecto.Adapters.Postgres
end
