defmodule Phxapp.UserController do
  use Phxapp, :controller
  alias DB.{Interface}
  plug :prevent_unauthorised_access when action in [:show]

  def show(conn, %{"id" => id}) do
    user_no_changeset = Interface.get_user(id)
    render(conn, "show.html", item: user_no_changeset)
  end

  def new(conn, _params) do
    user_no_changeset = Interface.new_user
    render(conn, "new.html", item: user_no_changeset )
  end

  def create(conn, %{"user" => params}) do
      case Interface.create_user(params) do
        {:ok, user } ->
          Interface.add_all_users_as_contacts(user)

          all_users_list = Interface.all_users()
          Enum.each(all_users_list, fn u ->
          if u.id != user.id do
            Phxapp.Endpoint.broadcast("user:#{u.id}", "new_contact", %{new_contact: user})
          end
          end)


          conn
          |> put_session(:current_user, user)
          |> put_session(:logged_in, true)
          |> redirect( to: Routes.chat_path(conn, :index))
        {:error, user} ->
          conn
          |> render("new.html", item: user)
      end
  end

  defp prevent_unauthorised_access(conn, _opts) do
    current_user = Map.get(conn.assigns, :current_user)

    requested_user_id =
      conn.params
      |> Map.get("id")
      |> String.to_integer()

    if current_user == nil || current_user.id != requested_user_id do
      conn
      |> redirect(to: Routes.session_path(conn, :index))
      |> halt()
    else
      conn
    end

  end


end
