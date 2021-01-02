defmodule DB.Chats do
use Ecto.Schema
alias DB.{Users, Messages, Users_Chats}
import Ecto.Changeset
@timestamp_options [type: :utc_datetime]
schema "chats" do
  field :chat_name, :string
  field :chat_type, :integer
  field :recipient_id_if_private_chat, :integer
  timestamps(@timestamp_options)

  belongs_to :creator, Users
  #xxx It won't let me use the same name as the belongs_to for the foreign_key, i.e. recipient_id_if_private_chat, which is what the column is in the database. I've tried to trick it, thus, but just taking the _chat off the belongs_to name here, and see if that works.

  #belongs_to :recipient_id_if_private, Users, foreign_key: :recipient_id_if_private_chat

  many_to_many :members, Users, join_through: Users_Chats
  has_many :messages, Messages, foreign_key: :chats_id
end

def changeset(item, params \\ %{chat_type: 1 }) do
  item
  |> cast(params, [:chat_name, :chat_type, :creator_id, :recipient_id_if_private_chat])
  |> validate_required([:chat_type, :creator_id])
end

end
