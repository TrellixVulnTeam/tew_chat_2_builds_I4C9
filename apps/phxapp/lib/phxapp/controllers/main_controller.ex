defmodule Phxapp.MainController do
  use Phxapp, :controller

  def index(conn, _opts) do
    logged_in? = get_session(conn, :logged_in)
    case logged_in? do
      true -> redirect(conn, to: Routes.chat_live_path(conn, :index))
      _ -> render conn, "index.html"
    end
  end
end
