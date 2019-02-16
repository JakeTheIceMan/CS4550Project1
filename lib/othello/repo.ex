defmodule Othello.Repo do
  use Ecto.Repo,
    otp_app: :othello,
    adapter: Ecto.Adapters.Postgres
end
