defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.GameServer

  intercept ["update"]

  def join("games:" <> game, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game, game)
      GameServer.start(game)
      {:ok, %{"join" => game, "game" => GameServer.view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("choose", %{"row" => r, "column" => c, "player" => p}, socket) do
    game = GameServer.choose(socket.assigns[:game], r, c, p)
    update!(game, socket)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("restart", _, socket) do
    game = GameServer.restart(socket.assigns[:game])
    update!(game, socket)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_out("update", game, socket) do
    IO.inspect("Broadcasting update to #{socket.assigns[:user]}")
    push(socket, "update", %{"game" => game})
    {:noreply, socket}
  end

  def update!(game, socket) do
    broadcast!(socket, "update", game)
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
