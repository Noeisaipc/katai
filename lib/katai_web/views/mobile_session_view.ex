defmodule KataiWeb.MobileSessionView do
  use KataiWeb, :view

  @spec render(String.t(), map()) :: struct()
  def render("sign_in.json", %{
        jwt: jwt}) do
    %{
      data: %{
        token: jwt,
      }
    }
  end

  @spec render(String.t(), map()) :: struct()
  def render("sign_in_error.json", %{message: message}) do
    %{
      message: message
    }
  end

  @spec render(String.t(), map()) :: struct()
  def render("sign_test.json", %{message: message}) do
    %{
      message: message
    }
  end

  @spec render(String.t(), map()) :: struct()
  def render("sign_out.json", %{message: message}) do
    %{
      message: message
    }
  end
end
