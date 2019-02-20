defmodule OthelloWeb.GamesChannel do
  use OthelloWeb, :channel

  alias Othello.GameServer

  intercept ["update"]

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      socket = socket
      |> assign(:name, name)
      GameServer.start(name)
      {:ok, %{"join" => name, "game" => GameServer.view(name)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("choose", %{"row" => r, "column" => c}, socket) do
    IO.inspect(socket.assigns[:name])
    game = GameServer.choose(socket.assigns[:name], r, c, socket.assigns[:user])
    update!(game, socket)
    {:reply, {:ok, %{"game" => game}}, socket}
  end

  def handle_in("restart", _, socket) do
    game = GameServer.restart(socket.assigns[:name])
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
