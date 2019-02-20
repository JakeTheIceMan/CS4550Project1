defmodule OthelloWeb.Plugs.PutUserToken do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    IO.inspect("Session user is now: #{get_session(conn, :user)}")
    if user = get_session(conn, :user) do
      token = Phoenix.Token.sign(conn, "user socket",  user)
      assign(conn, :user_token, token)
    else
      assign(conn, :user_token, "")
    end
  end
end
