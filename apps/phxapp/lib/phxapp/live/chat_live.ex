defmodule Phxapp.ChatLive do
  use Phxapp, :live_view
  alias DB.{Interface, Users, Messages, Chats, Users_Contacts}
  alias Phxapp.{ RenderMainScreen, RenderRealChat, ChatListObject, PrivateChat, FakeChat, InterMessageObject, NewPrivateChat, NewMessage}
  import Ecto.Query
  require Logger

  ################ General & System ####################

  def mount(_params, session, socket) do
    %{id: user_id, username: username } = Map.get(session, "current_user")
    current_user = Interface.get_user(user_id)
    render_screen_type = %RenderMainScreen{}

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Phxapp.PubSub, "user:#{user_id}")
    end

    old_data = Interface.get_old_data(user_id)
    chat_list_objects = build_chat_list_objects(old_data)

    socket = assign(socket, old_data: old_data, user_id: user_id, username: username, new_data: %{}, chat_list_objects: chat_list_objects, current_chat_object: nil, current_chat_object_id: 0, current_user: current_user,
    searched_clo: nil, searched_clos: []
    )

    socket = assign(socket, render_screen_type: render_screen_type)

    {:ok, socket}
  end

  def terminate(_reason, state) do
    IO.inspect "Terminating"
    case Interface.shutdown_sequence(state) do
    {:ok, message} -> IO.inspect message
    {:error, message} -> IO.inspect message
    end
    IO.inspect "Have a Nice Day :)"
  end


  ##############################################################

  ############# Setup Chats ####################

  def build_chat_list_objects(  %{user_details: user_details, chats: %{private_chats: private_chats, group_chats: _group_chats}, all_contacts_and_uc: all_contacts_and_uc} = _old_data) do

    user_id = user_details.id

    chat_list_objects =
          all_contacts_and_uc
          |> Enum.with_index()
          |> Enum.map( fn {%{contact: c, user_contact: uc}, i } ->
            new_contact_chat_list_object(c, uc, i)
          end )
          |> Enum.map( fn clo ->
            [contact_object | _t ] = clo.contact_objects
            chat_object = filter_private_chat_by_contact(private_chats, contact_object, user_id )
            clo =
            case chat_object do
              %Chats{} -> new_private_chat_list_object(clo, chat_object)
              _ -> clo
            end

            clo

          end )

    chat_list_objects =
        chat_list_objects
        |> Enum.with_index()
        |> Enum.into(%{}, fn {clo, i} ->
          struct(clo, chat_list_objects_id: i)
          {i, clo} end)


    chat_list_objects
  end




  def get_messages_by_chats_id(chats_id) do
    messages_query = from m in Messages,
                     where: m.chats_id == ^chats_id,
                     order_by: [desc: :inserted_at],
                     select: m
    Interface.get_all_query(messages_query)
  end

  def filter_private_chat_by_contact(private_chat_list, contact, this_user_id) do
    #xxx I think Enum.find is gonna output {key, val}, because we pass in a seris of Maps - c is a map - and so, I'd better change this to pattern match against {_k, v}
    #However - change back if it screws it up
     Enum.find( private_chat_list, fn c ->

      #[contact_object | _t ] = c.contact_objects
      (c.creator_id == this_user_id && c.recipient_id_if_private_chat == contact.id) || (c.creator_id == contact.id && c.recipient_id_if_private_chat == this_user_id)
    end )

  end

  def handle_info(%{event: "new_contact", payload: %{new_contact: new_user_struct} }, socket) do
    current_chat_list_objects = socket.assigns.chat_list_objects
    current_user = socket.assigns.current_user

    new_uc_struct_query = from uc in Users_Contacts,
                          where: uc.users_id == ^current_user.id and uc.contacts_id == ^new_user_struct.id,
                          select: uc
    [uc_struct] = Interface.get_all_query(new_uc_struct_query)
    number_of_chat_tabs = Enum.count(current_chat_list_objects)
    new_contact_clo =
      %ChatListObject{
        contact_objects: [new_user_struct],
        local_name: uc_struct.contact_name,
        chat_type: %FakeChat{},
        chat_object: nil,
        messages: [],
        chat_list_objects_id: number_of_chat_tabs
      }
      updated_chat_list_objects = Map.put(current_chat_list_objects, number_of_chat_tabs, new_contact_clo )
      socket = assign(socket, chat_list_objects: updated_chat_list_objects )
    {:noreply, socket}
  end

  def handle_info(%{event: "new_message", payload: inter_message_object}, socket) do
    chat_list_objects = socket.assigns.chat_list_objects
    current_chat_object = socket.assigns.current_chat_object
    received_chat_struct = inter_message_object.chat_object
    {_i, target_chat_object} = Enum.find(chat_list_objects, fn {_i, clo} ->

      case clo.chat_object do
        nil -> false
        %Chats{} ->  clo.chat_object.id == received_chat_struct.id
      end
    end)

    new_message = inter_message_object.message_data
    old_messages = target_chat_object.messages

    updated_chat_object = struct(target_chat_object, messages: [ new_message | old_messages] )

    target_chat_object_id = target_chat_object.chat_list_objects_id
    updated_current_chat_object =
    if current_chat_object == nil do
      current_chat_object

    else
      case target_chat_object_id == current_chat_object.chat_list_objects_id do
        true -> updated_chat_object
        false -> current_chat_object
      end

    end

    chat_list_objects = Map.put(chat_list_objects, target_chat_object_id, updated_chat_object )
    socket = assign(socket, chat_list_objects: chat_list_objects, current_chat_object: updated_current_chat_object)
    {:noreply, socket}
  end

  def handle_info(%{event: "new_chat", payload: inter_message_object }, socket) do
    chat_list_objects = socket.assigns.chat_list_objects
    chat_list_objects = install_new_chat(inter_message_object, chat_list_objects)
    current_chat_object = socket.assigns.current_chat_object

    socket =
    case current_chat_object do
      nil -> assign(socket, chat_list_objects: chat_list_objects)
      x when is_integer(x)  ->
        current_chat_list_objects_id = socket.assigns.current_chat_object.chat_list_objects_id

        socket = assign(socket, chat_list_objects: chat_list_objects, current_chat_object: Map.get(chat_list_objects, current_chat_list_objects_id))
        socket
    end
    {:noreply, socket}
  end

  def install_new_chat( %InterMessageObject{} = inter_message_object, chat_list_objects) do

    chat_list_objects =
    case inter_message_object.inter_message_type do
      %NewPrivateChat{} ->

      sender_object_id = inter_message_object.sender_object.id
       [local_contact_id] = for {k, %ChatListObject{contact_objects: [%{id: ^sender_object_id}]} } <- chat_list_objects, do: k

       contact_clo = Map.get(chat_list_objects, local_contact_id)
       clo = new_private_chat_list_object(contact_clo, inter_message_object.chat_object )

       Map.put(chat_list_objects, local_contact_id, clo)
      _ -> raise "Whoops, tried to install a new chat, but the InterMessageObject had an incorrect inter_message_type - install_new_chat" #NOTE - Group Chat Setup goes here - put in option for group chat installation here, before raise :)

    end
    chat_list_objects
  end

  def filter_contact_search(search_term, chat_list_objects) do
    if search_term == "" do
      []

    else

      Enum.into(chat_list_objects, [], fn {_i, clo} -> clo end)
      |> Enum.filter( fn clo ->

        #Group Chat Setup Goes here! Only put in support for private chat in the case do, below :)
        result =
        case clo.chat_type do
          _ ->
          String.contains?(String.downcase(clo.local_name), String.downcase(search_term))
        end

        result
      end)
      |> Enum.into([], fn clo ->
        {clo.chat_list_objects_id, clo.local_name}
      end)
    end

  end

  def handle_event("found_chat", %{"searched_clo" => searched_clo}, socket) do
    chat_list_objects = socket.assigns.chat_list_objects
    match =
      chat_list_objects
      |> Enum.find(fn {_i, clo} ->
        String.downcase(clo.local_name) == String.downcase(searched_clo)
      end)
        {render_screen_type, current_chat_object, searched_clo} =
    case match do
      nil ->
        {%RenderMainScreen{}, socket.assigns.current_chat_object, searched_clo}
      {_i, %ChatListObject{} = found_clo} ->
        {%RenderRealChat{}, found_clo, searched_clo}
    end
    socket= assign(socket, searched_clo: searched_clo, current_chat_object: current_chat_object, render_screen_type: render_screen_type)
    {:noreply, socket}
  end

  def handle_event("search_chats", %{"searched_clo" => search}, socket) do
    chat_list_objects = socket.assigns.chat_list_objects

    socket =
    case chat_list_objects |> Enum.count() do
      0 -> socket
     x when x > 0 -> clo_results = filter_contact_search(search, chat_list_objects)
          socket = assign(socket, searched_clos: clo_results)
          socket
    end

    {:noreply, socket}
  end

  def handle_event("logout", _, socket) do
    socket = redirect(socket, to: Routes.session_path(socket, :delete))
    {:noreply, socket}
  end

  def handle_event("control_center_clicked", _params, socket) do
    render_screen_type = %RenderMainScreen{}
    socket = assign(socket, render_screen_type: render_screen_type)
    {:noreply, socket}
  end

  def handle_event("chat_tab_clicked", %{"chat_list_id" => chat_list_objects_id }, socket) do
    chat_list_objects = socket.assigns.chat_list_objects
    chat_list_objects_id = String.to_integer(chat_list_objects_id)

    new_current_chat_object = Map.get(chat_list_objects, chat_list_objects_id)

    render_screen_type = %RenderRealChat{}
    socket = assign(socket, current_chat_object: new_current_chat_object, render_screen_type: render_screen_type )
    {:noreply, socket}
  end

  def handle_event("send_button_clicked", %{"msg_text" => msg_text} = msg, socket ) do

    socket =
      case msg_text do
        "" -> socket

        _ ->


    %{current_chat_object: current_chat_object,
    current_user: current_user, chat_list_objects: chat_list_objects
  } = socket.assigns

  #If I don't want the target object to be the current_chat_object, then change it here! :)
  target_chat_object = current_chat_object

  target_chat_list_objects_id = target_chat_object.chat_list_objects_id

  #Basically - we're sending a message. If the current chat is a %FakeChat{}, then we know we want to creat a new chat. Otherwise, we're targeting one that already exists, and must be in our records etc. Thus Global Chat Setup goes here.

  recipient_ids = get_recipient_ids_from_clo( target_chat_object )

  { updated_chat_list_objects, inter_message_object} =
  case target_chat_object.chat_type do
    %FakeChat{} -> #Group Chat Setup goes here
      # xxx Refactor all the common bits here, in this case do, into a single, external function

      [recipient_id | _t] = recipient_ids
      [contact | _t] = target_chat_object.contact_objects
      new_chat_params = %{
        chat_name: target_chat_object.local_name,
        creator_id: current_user.id,
        chat_type: 1,
        recipient_id_if_private_chat: contact.id
      }
      {:ok, new_chat_struct} = Interface.create_chat( new_chat_params )
      new_message_params = %{
        msg_text: msg["msg_text"],
        chats_id: new_chat_struct.id,
        sender_id: current_user.id
      }

      {:ok, new_message_struct} = Interface.create_message(new_message_params)

      all_recipients_query = from u in Users,
                             where: u.id in ^recipient_ids,
                             select: u
      recipients = Interface.get_all_query(all_recipients_query)
      users_structs_list = [current_user | recipients ]
      :ok = Interface.associate_chat_with_users(users_structs_list, new_chat_struct)

      #Don't associate a new Contact Name with User_Contacts, because it hasn't changed since the contact was added - you change it in a different (as yet unwritten) function xxx

      updated_target_clo = struct(target_chat_object, chat_type: %PrivateChat{}, chat_object: new_chat_struct, messages: [ new_message_struct] )



      #xxx Do ASSOCIATIONS!!!!! For goodness sake, build the associations! :)

      updated_chat_list_objects = Map.put(chat_list_objects, updated_target_clo.chat_list_objects_id, updated_target_clo )

      {updated_chat_list_objects, build_send_new_private_chat_object( recipient_id, current_user  )}

    %PrivateChat{} ->
      #Add the new message into the sender's local system (clo, current_chat_object, etc)

      # xxx Refactor all the common bits here, in this case do, into a single, external function
      new_message_params = %{
        msg_text: msg_text,
        chats_id: target_chat_object.chat_object.id,
        sender_id: current_user.id
      }

      {:ok, new_message_struct} = Interface.create_message(new_message_params)

      updated_target_clo = update_clo_with_new_message( target_chat_object, new_message_struct)

      updated_chat_list_objects = Map.put(chat_list_objects, updated_target_clo.chat_list_objects_id, updated_target_clo )

      { updated_chat_list_objects , build_send_message_object(target_chat_object,
      new_message_struct, current_user)}


  end

  #Remember, chat_list_objects_id is the local id of the chat in the chat_lists_objects map, that populates the chats tab column :)


  send_new_inter_user_process_message( inter_message_object, recipient_ids )

  updated_current_chat_object =
  case inter_message_object.inter_message_type do
    %NewPrivateChat{} ->
      Map.get(updated_chat_list_objects, target_chat_list_objects_id)
    %NewMessage{} ->
        Map.get(updated_chat_list_objects, target_chat_list_objects_id)
  end

  socket = assign(socket, chat_list_objects: updated_chat_list_objects, current_chat_object: updated_current_chat_object ) ### Add current_chat_object # xxx check i haven't used spelling current_chat_list_object
  socket

      end

    {:noreply, socket}
  end





  def update_clo_with_new_message( %ChatListObject{} = clo, new_message ) do
    current_messages = clo.messages
    struct(clo, messages: [new_message | current_messages])
  end

  def send_new_inter_user_process_message( %InterMessageObject{} = inter_message_type_struct, recipient_ids) do

    broadcast_subtopic =
      case inter_message_type_struct.inter_message_type do
        %NewPrivateChat{} -> "new_chat"
        %NewMessage{} -> "new_message"
      end

    Enum.each(recipient_ids, fn id ->
      Phxapp.Endpoint.broadcast("user:#{id}", broadcast_subtopic, inter_message_type_struct )
    end)
  end

  #This function builds a message object for any chat type - Private, Group, etc
  #Thus, the Chat List Object the message will go to is supplied, and the appropriate IMO is built.
  def build_send_message_object( %ChatListObject{} = chat_list_object, new_message_struct, %Users{} = user_struct) do
    chat_struct = chat_list_object.chat_object
    %InterMessageObject{
      sender_object: user_struct,
      message_data: new_message_struct,
      chat_object: chat_struct,
      inter_message_type: %NewMessage{}
    }

  end


  def build_send_new_private_chat_object( recipient_id, user_struct  ) do
    chat_query = from c in Chats,
                 where: c.recipient_id_if_private_chat == ^recipient_id,
                 select: c
    [chat_struct] = Interface.get_all_query(chat_query)
    #To Send
    #InterChatListObject, with:
    #This %User{} struct
    #%Chat{} of the new chat added to the DB
    # STRUCT that explains the type of this message
    %InterMessageObject{
      sender_object: user_struct,
      chat_object: chat_struct,
      inter_message_type: %NewPrivateChat{}
    }
  end

  def new_contact_chat_list_object(_contact_object = c, _uc_object = uc, i \\ 0) do

    %ChatListObject{
      contact_objects: [c],
      local_name: uc.contact_name,
      chat_type: %FakeChat{},
      messages: [],
      chat_list_objects_id: i
    }
  end


  def new_private_chat_list_object( %ChatListObject{} = clo, %Chats{} = chat_object  ) do

    struct(clo, chat_object: chat_object   )
    |> struct(chat_type: %PrivateChat{})
    |> struct(messages: get_messages_by_chats_id( chat_object.id ))

  end

  def get_recipient_ids_from_clo( %ChatListObject{} = current_chat_object ) do

    case current_chat_object.chat_type do
      %FakeChat{} ->
        Enum.map(current_chat_object.contact_objects, fn clo ->
          clo.id
        end)
      %PrivateChat{} ->
        Enum.map(current_chat_object.contact_objects, fn clo ->
          clo.id
        end)

      _ ->
        #This is intended for Group Chat stuff, but haven't set that up yet, so Group Chat setup stuff goes here :)
        raise "Didn't Supply The Right current_chat_object.chat_type - get_recipient_ids_from_clo "

    end
  end


end
