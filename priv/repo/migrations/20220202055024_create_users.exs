defmodule Katai.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :password, :string
      add :public_key, :text

      timestamps()
    end

  end
end
