defmodule Phxapp.InterMessageObject do
  #alias Phxapp.{NewMessage, NewPrivateChat, NewGroupChat, %Users{}}
  defstruct [
    sender_object: nil, ## %Users{} from databas, here
    message_data: %{msg_text: ""},
    chat_object: nil,
    inter_message_type: nil #Either - %NewMessage{}, %NewPrivateChat{}, %NewGroupChat
  ]
end
