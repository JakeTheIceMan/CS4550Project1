defmodule Othello.GameServer do
  use GenServer

  def reg(name) do
    {:via, Registry, {Othello.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    Othello.GameSup.start_child(spec)
  end

  def start_link(name) do
    game = Othello.BackupAgent.get(name) || Othello.Game.new()
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def choose(name, r, c, player) do
    GenServer.call(reg(name), {:choose, name, r, c, player})
  end

  def restart(name) do
    GenServer.call(reg(name), {:restart, name})
  end

  def view(name) do
    GenServer.call(reg(name), {:view, name})
  end

  def init(game) do
    {:ok, game}
  end

  def handle_call({:choose, name, r, c, player}, _from, game) do
    game = Othello.Game.choose(game, r, c, player)
    Othello.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:restart, name}, _from, game) do
    new_game = Othello.Game.new()
    Othello.BackupAgent.put(name, new_game)
    IO.inspect(Othello.BackupAgent.get(name))
    {:reply, new_game, game}
  end

  def handle_call({:view, _name}, _from, game) do
    view = Othello.Game.client_view(game)
    {:reply, view, game}
  end
end
