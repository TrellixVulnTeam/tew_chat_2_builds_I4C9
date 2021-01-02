defmodule DB.Interface do
  alias DB.{Repo, Users, Chats, Users_Chats, Users_Contacts, Messages, Password}
 # alias Phxapp.{ChatListObject, FakeChat, PrivateChat, GroupChat}
  import Ecto.Query
  require Logger
  @moduledoc """
  Documentation for `Db`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Db.hello()
      :world

  """



  ## Get Query

  def get_all_query(query) do
    Repo.all(query)
  end
  #######

  def all_users() do
    Repo.all(Users)
  end

  def get_user(id) do
    Repo.get(Users, id)
  end

  def new_user() do
    %Users{}
    |> Users.changeset
  end

  def create_user(params) do
    %Users{}
    |> Users.changeset_with_password(params)
    |> Repo.insert
  end

  def delete_user(id) do
    Repo.delete(User, id)
  end

  def edit_user(id) do
    Repo.get(User, id)
    |> Users.changeset
  end

  def update_user(id, params) do
    Repo.get(Users, id)
    |> Users.changeset(params)
    |> Repo.update
  end

  ############

  def all_chats() do
    Repo.all(Chats)
  end

  def get_chat(id) do
    Repo.get(Chats, id)
  end

  def new_chat() do
    %Chats{}
    |> Chats.changeset
  end

  def put_assoc_recipient_id_if_private_chat(chat_struct, recipient_id) do
    chat_struct
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:recipient_id_if_private_chat, [recipient_id])
    |> Repo.update
  end

  def create_chat(params) do
    %Chats{}
    |> Chats.changeset(params)
    |> Repo.insert
  end

  def edit_chat(id) do
    Repo.get(Chats, id)
    |> Chats.changeset
  end

  def update_chat(id, params) do
    Repo.get(Chats, id)
    |> Chats.changeset(params)
    |> Repo.update
  end

  def delete_chat(id) do
    Repo.delete(Chats, id)
  end

  ##### Messages

  def all_messages() do
    Repo.all(Messages)
  end

  def get_message(id) do
    Repo.get(Messages, id)
  end

  def new_message() do
    %Messages{}
    |> Messages.changeset
  end

  def create_message(params) do
    %Messages{}
    |> Messages.changeset(params)
    |> Repo.insert
  end

  def edit_message(id) do
    Repo.get(Messages, id)
    |> Messages.changeset
  end

  def update_message(id, params) do
    Repo.get(Messages, id)
    |> Messages.changeset(params)
    |> Repo.update
  end

  def delete_message(id) do
    Repo.delete(Messages, id)
  end

  ### Update Users_Conacts

  def update_users_contacts_details( users_contacts_struct, params \\ %{}) do
    users_contacts_struct
    |> Users_Contacts.changeset(params)
    |> Repo.update
  end

  ## Session

  def get_user_by_username_and_password(username, password) do
    with user when not is_nil(user) <- Repo.get_by(Users, %{username: username}),
         true <- Password.verify_password(password, user.hashed_password) do
      user
    else
      _ -> Password.dummy_verify
    end
  end

 #### Shutdown Sequence



 def shutdown_sequence(state) do
  _assigns = state.assigns
  msg = "Successfully saved state to database! Though, actually not, cause it was all saved over the course of use :)"
  {:ok, msg}
end








  ###############################


  ### Contacts


  def add_all_users_as_contacts(user) do
    user_id = user.id
    user = get_user(user_id)
    all_users = all_users()

    Enum.each(all_users, fn u ->

      if u.id != user_id do

        u_p =
        u
        |> Repo.preload(:contacts)
        u_c =
        u_p
        |> Ecto.Changeset.change
        u_ready =
        u_c
        |> Ecto.Changeset.put_assoc(:contacts, [user | u_p.contacts])
        _result =
        u_ready
        |> Repo.update
        #xxx add user_contact contact_name, here! :)
        uc_query = from uc in Users_Contacts,
                   where: uc.users_id == ^u.id and uc.contacts_id == ^user_id,
                   select: uc
        [uc_struct] = get_all_query(uc_query)
        uc_params = %{contact_name: user.username}

        update_users_contacts_details( uc_struct, uc_params )

      #  Phxapp.Endpoint.broadcast("user:#{u.id}", "new_contact", %{new_contact: user})

        user_p =
        user
        |> Repo.preload(:contacts)
        _result_2 =
        user_p
        |> Ecto.Changeset.change
        |> Ecto.Changeset.put_assoc(:contacts, [u |> Repo.preload(:contacts) | user_p.contacts ])
        |> Repo.update

        uc_query = from uc in Users_Contacts,
                   where: uc.users_id == ^user_id and uc.contacts_id == ^u.id,
                   select: uc
        [uc_struct] = get_all_query(uc_query)
        uc_params = %{contact_name: u.username}
        update_users_contacts_details( uc_struct, uc_params )

      end


    end)
  end







  ######### Main App Functions #########

  def get_old_data(user_id) do
    user_details = get_user(user_id)
    all_contacts_and_uc_query = from uc in Users_Contacts,
                         where: uc.users_id == ^user_id,
                         join: c in Users,
                         on: uc.contacts_id == c.id,
                         select: %{contact: c, user_contact: uc}
    all_contacts_and_uc = get_all_query(all_contacts_and_uc_query)
    all_chats_query = from uc in Users_Chats,
                         where: uc.users_id == ^user_id,
                         join: c in Chats,
                         on: uc.chats_id == c.id,
                         select: c
    all_chats = get_all_query(all_chats_query)
    private_chats = Enum.filter(all_chats, fn c ->
      case c.chat_type do
        1 -> true # chat_type == 1 means Private Chat
        _ -> false
      end
    end)
    IO.inspect "This is the private_chats"
    IO.inspect private_chats
    IO.inspect "33333333333"
    group_chats = Enum.filter(all_chats, fn c ->
      case c.chat_type do
        2 -> true # chat_type == 2 means Group Chat
        _ -> false
      end
    end)

  %{user_details: user_details, chats: %{private_chats: private_chats, group_chats: group_chats}, all_contacts_and_uc: all_contacts_and_uc}

    #### PUT THE GROUP STUFF HERE
    #Group Setup Goes Here

  end

  def associate_chat_with_users(users_structs_list, chat_struct) do

    Enum.each(users_structs_list, fn u_struct ->

      u_struct_p = u_struct |> Repo.preload(:chats)

      u_struct_p
      |> Ecto.Changeset.change
      |> Ecto.Changeset.put_assoc(:chats, [chat_struct | u_struct_p.chats ])
      |> Repo.update
    end)

  end


end
