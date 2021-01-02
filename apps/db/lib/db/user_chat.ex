defmodule DB.Users_Chats do
  use Ecto.Schema

  @primary_key false
  schema "users_chats" do
    field :users_id, :id, primary_key: true
    field :chats_id, :id, primary_key: true
  end

end
