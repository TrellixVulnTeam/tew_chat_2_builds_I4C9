defmodule Phxapp.SessionController do
  use Phxapp, :controller
  alias DB.{Interface, Users}
  def new(conn, _params) do
    render conn, "login.html"
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case Interface.get_user_by_username_and_password(username, password) do
      %Users{} = user ->



          conn
          |> put_session(:current_user, user)
          |> put_session(:logged_in, true)
          |> redirect(to: Routes.chat_path(conn, :index))

        _ ->
          conn
          |> render("login.html")

    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: Routes.main_path(conn, :index))
  end

end
