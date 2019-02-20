defmodule OthelloWeb.PageController do
  use OthelloWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def join(conn, %{"join" => %{"user" => user, "name" => name}}) do
    conn
    |> put_session(:user, user)
    |> redirect(to: "/game/#{name}")
  end

  def game(conn, params) do
    user = get_session(conn, :user)
    if user do
      render conn, "game.html", name: params["name"], user: user
    else
      conn
      |> put_flash(:error, "Please pick a color.")
      |> redirect(to: "/")
    end
  end
end
