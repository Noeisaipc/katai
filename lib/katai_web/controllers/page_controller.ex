defmodule KataiWeb.PageController do
  use KataiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
