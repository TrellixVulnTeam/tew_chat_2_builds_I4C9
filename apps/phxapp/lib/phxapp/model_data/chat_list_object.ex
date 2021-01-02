defmodule Phxapp.ChatListObject do
  alias Phxapp.{FakeChat}


  defstruct [
    contact_objects: [], #A %Users{} struct
 #   group_chat_contact_objects: %{}, #Global Chat Sethup goes here
    local_name: "",
    chat_type: %FakeChat{},
    chat_object: nil,
    messages: [],
    chat_list_objects_id: 0
  ]

end
