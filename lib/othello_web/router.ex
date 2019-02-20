defmodule OthelloWeb.Router do
  use OthelloWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug OthelloWeb.Plugs.PutUserToken
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OthelloWeb do
    pipe_through :browser
    post "/join", PageController, :join
    get "/game/:name", PageController, :game
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", OthelloWeb do
  #   pipe_through :api
  # end
end
