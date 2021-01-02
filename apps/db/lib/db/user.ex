defmodule DB.Users do
  use Ecto.Schema
  import Ecto.Changeset
  alias DB.{Users_Contacts, Chats, Password, Users_Chats, Messages}

  @timestamp_options [type: :utc_datetime]
  schema "users" do
    field :username, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    timestamps(@timestamp_options)

    many_to_many :contacts, __MODULE__, join_through: Users_Contacts, join_keys: [users_id: :id, contacts_id: :id]
    has_many :messages, Messages, foreign_key: :sender_id

    #has_many :private_chats, Chats, foreign_key: :recipient_id_if_private_chat

    many_to_many :chats, Chats, join_through: Users_Chats

  end

  def changeset(item, params \\ %{}) do
    item
    |> cast(params, [:username])
    |> validate_required([:username])
    |> unique_constraint([:username])
  end

  def changeset_with_password(item, params \\ %{}) do
    item
    |> cast(params, [:password])
    |> validate_required([:password])
    |> hash_password()
    |> changeset(params)
  end

  def hash_password(%Ecto.Changeset{changes: %{password: password}} = changeset) do
    changeset
    |> put_change(:hashed_password, Password.hash_password(password))
  end

end
