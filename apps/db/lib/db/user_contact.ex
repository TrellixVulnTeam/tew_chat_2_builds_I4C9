defmodule DB.Users_Contacts do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key false
  schema "users_contacts" do
    field :users_id, :id, primary_key: true
    field :contacts_id, :id, primary_key: true
    field :contact_name, :string
  end

  def changeset(item, params \\ %{}) do
    item
    |> cast(params, [:contact_name])
  end

end
