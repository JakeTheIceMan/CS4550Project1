defmodule OthelloWeb.PageController do
  use OthelloWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # Set up a user to join a given game.
  def join(conn, %{"join" => %{"user" => user, "name" => name}}) do
    # Put the user in the current session, and redirect them to the game.
    conn
    |> put_session(:user, user)
    |> redirect(to: "/game/#{name}")
  end

  # Show a game state.
  def game(conn, params) do
    user = get_session(conn, :user)
    # If a user is present,
    if user do
      # Render the game for the given user.
      render conn, "game.html", name: params["name"], user: user
    # Otherwise,
    else
      # Tell the user to pick a color and redirect them to the index.
      conn
      |> put_flash(:error, "Please pick a color.")
      |> redirect(to: "/")
    end
  end
end
