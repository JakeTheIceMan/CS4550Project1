defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel
  alias Othello.GameServer

  intercept ["update"]

  # Join a game.
  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :name, name)
      GameServer.start(name)
      {:ok, %{"join" => name, "game" => GameServer.view(name)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Allow a given player to make a move in a game.
  def handle_in("choose", %{"row" => r, "column" => c}, socket) do
    game = GameServer.choose(socket.assigns[:name], r, c, socket.assigns[:user])
    update!(game, socket)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  # Restart a game.
  def handle_in("restart", _, socket) do
    game = GameServer.restart(socket.assigns[:name])
    update!(game, socket)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  # Format the updated push message.
  def handle_out("update", game, socket) do
    push(socket, "update", %{"game" => game})
    {:noreply, socket}
  end

  # Private function that broadcasts the game state to all users.
  defp update!(game, socket) do
    broadcast!(socket, "update", game)
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
