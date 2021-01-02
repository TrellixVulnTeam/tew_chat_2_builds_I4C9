defmodule DB.Messages do
  use Ecto.Schema
  import Ecto.Changeset
  alias DB.{Chats, Users}

  @timestamp_options [type: :utc_datetime]
  schema "messages" do
    field :msg_text, :string
    field :received, :boolean
    field :seen, :boolean

    timestamps(@timestamp_options)

    belongs_to :chats, Chats, foreign_key: :chats_id
    belongs_to :sender, Users, foreign_key: :sender_id
  end

  def changeset_update(item, params \\ %{received: false, seen: false}) do
    item
    |> cast(params, [:msg_text, :chats_id, :sender_id, :received, :seen])
    |> validate_required([:chats_id, :sender_id])
  end

  def changeset(item, params \\ %{received: false, seen: false}) do
    item
    |> cast(params, [:msg_text, :chats_id, :sender_id, :received, :seen])
    |> validate_required([:msg_text, :chats_id, :sender_id])
  end



end
