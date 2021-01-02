defmodule Phxapp.ChatScreenLive do
  use Phxapp, :live_component

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def message_class(message_id, user_id) do
    case message_id do
      ^user_id -> 'my_message'
        _ -> 'their_message'
    end
  end

end
